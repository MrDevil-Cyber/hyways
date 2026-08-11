import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { createHash, randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

type SafeUser = { id: string; name: string; email: string; role: Role };

type RefreshPayload = {
  sub: string;
  sid: string;
  jti: string;
  typ: 'refresh';
  exp: number;
};

type TokenPair = {
  accessToken: string;
  refreshToken: string;
  refreshExpiresAt: Date;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    const exists = await this.prisma.user.findUnique({ where: { email } });
    if (exists) throw new ConflictException('Email is already registered');
    const user = await this.prisma.user.create({
      data: {
        name: dto.name.trim(),
        email,
        passwordHash: await bcrypt.hash(dto.password, 12),
      },
      select: { id: true, name: true, email: true, role: true },
    });
    return this.createSession(user);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email.trim().toLowerCase() },
    });
    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Invalid email or password');
    }
    return this.createSession({
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    });
  }

  async me(userId: string): Promise<SafeUser> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true, email: true, role: true },
    });
    if (!user) throw new UnauthorizedException('User no longer exists');
    return user;
  }

  async refresh(refreshToken: string) {
    const payload = await this.verifyRefreshToken(refreshToken);
    const now = new Date();
    const session = await this.prisma.authSession.findFirst({
      where: {
        id: payload.sid,
        userId: payload.sub,
        revokedAt: null,
        expiresAt: { gt: now },
      },
      select: {
        id: true,
        user: { select: { id: true, name: true, email: true, role: true } },
      },
    });
    if (!session) throw new UnauthorizedException('Refresh session expired');

    const nextTokens = await this.signTokenPair(session.user, session.id);
    const rotated = await this.prisma.authSession.updateMany({
      where: {
        id: session.id,
        userId: payload.sub,
        refreshTokenHash: this.hashToken(refreshToken),
        revokedAt: null,
        expiresAt: { gt: now },
      },
      data: {
        refreshTokenHash: this.hashToken(nextTokens.refreshToken),
        expiresAt: nextTokens.refreshExpiresAt,
        lastUsedAt: now,
      },
    });

    if (rotated.count !== 1) {
      await this.prisma.authSession.updateMany({
        where: { id: session.id, revokedAt: null },
        data: { revokedAt: now },
      });
      throw new UnauthorizedException('Refresh token reuse detected');
    }

    return {
      user: session.user,
      accessToken: nextTokens.accessToken,
      refreshToken: nextTokens.refreshToken,
    };
  }

  async logout(refreshToken: string): Promise<{ message: string }> {
    try {
      const payload = await this.verifyRefreshToken(refreshToken, true);
      await this.prisma.authSession.updateMany({
        where: { id: payload.sid, userId: payload.sub, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    } catch {
      // Logout is idempotent. The client still removes its secure local copy.
    }
    return { message: 'Logged out successfully' };
  }

  private async createSession(user: SafeUser) {
    const sessionId = randomUUID();
    const tokens = await this.signTokenPair(user, sessionId);
    await this.prisma.authSession.create({
      data: {
        id: sessionId,
        userId: user.id,
        refreshTokenHash: this.hashToken(tokens.refreshToken),
        expiresAt: tokens.refreshExpiresAt,
      },
    });
    return {
      user,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    };
  }

  private async signTokenPair(
    user: SafeUser,
    sessionId: string,
  ): Promise<TokenPair> {
    const issuer = this.config.get<string>('JWT_ISSUER', 'hyway-api');
    const audience = this.config.get<string>('JWT_AUDIENCE', 'hyway-mobile');
    const [accessToken, refreshToken] = await Promise.all([
      this.jwt.signAsync(
        {
          sub: user.id,
          sid: sessionId,
          jti: randomUUID(),
          email: user.email,
          role: user.role,
          typ: 'access',
        },
        {
          secret: this.config.getOrThrow('JWT_ACCESS_SECRET'),
          expiresIn: this.config.get('JWT_ACCESS_EXPIRES_IN', '15m'),
          issuer,
          audience,
        },
      ),
      this.jwt.signAsync(
        {
          sub: user.id,
          sid: sessionId,
          jti: randomUUID(),
          typ: 'refresh',
        },
        {
          secret: this.config.getOrThrow('JWT_REFRESH_SECRET'),
          expiresIn: this.config.get('JWT_REFRESH_EXPIRES_IN', '30d'),
          issuer,
          audience,
        },
      ),
    ]);
    const decoded = await this.jwt.verifyAsync<RefreshPayload>(refreshToken, {
      secret: this.config.getOrThrow('JWT_REFRESH_SECRET'),
      issuer,
      audience,
    });
    if (!decoded.exp) {
      throw new UnauthorizedException('Could not create refresh session');
    }
    return {
      accessToken,
      refreshToken,
      refreshExpiresAt: new Date(decoded.exp * 1000),
    };
  }

  private async verifyRefreshToken(
    refreshToken: string,
    ignoreExpiration = false,
  ): Promise<RefreshPayload> {
    let payload: RefreshPayload;
    try {
      payload = await this.jwt.verifyAsync<RefreshPayload>(refreshToken, {
        secret: this.config.getOrThrow('JWT_REFRESH_SECRET'),
        issuer: this.config.get<string>('JWT_ISSUER', 'hyway-api'),
        audience: this.config.get<string>('JWT_AUDIENCE', 'hyway-mobile'),
        ignoreExpiration,
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
    if (
      payload.typ !== 'refresh' ||
      !payload.sub ||
      !payload.sid ||
      !payload.jti
    ) {
      throw new UnauthorizedException('Invalid refresh token');
    }
    return payload;
  }

  private hashToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }
}
