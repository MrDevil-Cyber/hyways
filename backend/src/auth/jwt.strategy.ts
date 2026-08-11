import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthUser } from './decorators/current-user.decorator';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>('JWT_ACCESS_SECRET'),
      issuer: config.get<string>('JWT_ISSUER', 'hyway-api'),
      audience: config.get<string>('JWT_AUDIENCE', 'hyway-mobile'),
    });
  }

  async validate(payload: AuthUser): Promise<AuthUser> {
    if (payload.typ !== 'access' || !payload.sid) {
      throw new UnauthorizedException('Invalid access token');
    }
    const session = await this.prisma.authSession.findFirst({
      where: {
        id: payload.sid,
        userId: payload.sub,
        revokedAt: null,
        expiresAt: { gt: new Date() },
      },
      select: {
        id: true,
        user: { select: { id: true, email: true, role: true } },
      },
    });
    if (!session) throw new UnauthorizedException('Session is no longer valid');
    return {
      sub: session.user.id,
      sid: session.id,
      email: session.user.email,
      role: session.user.role,
      typ: 'access',
    };
  }
}
