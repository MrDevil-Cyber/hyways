import { UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from './auth.service';

type FakeUser = {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  company: string | null;
  jobTitle: string | null;
  city: string | null;
  state: string | null;
  passwordHash: string;
  role: Role;
};

type FakeSession = {
  id: string;
  userId: string;
  refreshTokenHash: string;
  expiresAt: Date;
  revokedAt: Date | null;
  lastUsedAt: Date;
};

describe('AuthService persistent sessions', () => {
  const users = new Map<string, FakeUser>();
  const sessions = new Map<string, FakeSession>();
  let service: AuthService;
  let user: FakeUser;

  const configValues: Record<string, string> = {
    JWT_ACCESS_SECRET: 'test-access-secret-at-least-thirty-two-characters',
    JWT_REFRESH_SECRET: 'test-refresh-secret-at-least-thirty-two-characters',
    JWT_ACCESS_EXPIRES_IN: '15m',
    JWT_REFRESH_EXPIRES_IN: '30d',
    JWT_ISSUER: 'hyway-api',
    JWT_AUDIENCE: 'hyway-mobile',
  };

  beforeAll(async () => {
    user = {
      id: 'user-1',
      name: 'HYWAY Customer',
      email: 'customer@example.com',
      phone: '+91 98765 43210',
      company: 'HYWAY Customer Co.',
      jobTitle: 'Plant Manager',
      city: 'Pune',
      state: 'Maharashtra',
      passwordHash: await bcrypt.hash('Password123!', 4),
      role: Role.CUSTOMER,
    };
  });

  beforeEach(() => {
    users.clear();
    users.set(user.id, user);
    sessions.clear();

    const prisma = {
      user: {
        findUnique: jest.fn(
          ({
            where,
            select,
          }: {
            where: Record<string, string>;
            select?: Record<string, boolean>;
          }) => {
            if (where.id) {
              const value = users.get(where.id);
              if (!value) return null;
              return select ? safeUser(value) : value;
            }
            if (where.email) {
              return (
                [...users.values()].find(
                  (value) => value.email === where.email,
                ) ?? null
              );
            }
            return null;
          },
        ),
        create: jest.fn(),
      },
      authSession: {
        create: jest.fn(
          ({
            data,
          }: {
            data: Omit<FakeSession, 'revokedAt' | 'lastUsedAt'>;
          }) => {
            const value: FakeSession = {
              ...data,
              revokedAt: null,
              lastUsedAt: new Date(),
            };
            sessions.set(value.id, value);
            return value;
          },
        ),
        findFirst: jest.fn(({ where }: { where: Record<string, unknown> }) => {
          const value = sessions.get(where.id as string);
          if (!value || !matches(value, where)) return null;
          const owner = users.get(value.userId);
          return owner ? { id: value.id, user: safeUser(owner) } : null;
        }),
        updateMany: jest.fn(
          ({
            where,
            data,
          }: {
            where: Record<string, unknown>;
            data: Partial<FakeSession>;
          }) => {
            let count = 0;
            for (const [id, value] of sessions) {
              if (!matches(value, where)) continue;
              sessions.set(id, { ...value, ...data });
              count++;
            }
            return { count };
          },
        ),
      },
    } as unknown as PrismaService;

    const config = {
      get: (key: string, fallback?: string) => configValues[key] ?? fallback,
      getOrThrow: (key: string) => {
        const value = configValues[key];
        if (value == null) throw new Error(`Missing ${key}`);
        return value;
      },
    } as unknown as ConfigService;

    service = new AuthService(prisma, new JwtService(), config);
  });

  it('keeps independent sessions valid across multiple logins', async () => {
    const first = await login();
    const second = await login();

    expect(first.refreshToken).not.toBe(second.refreshToken);
    expect(sessions.size).toBe(2);
    expect([...sessions.values()][0].refreshTokenHash).not.toContain(
      first.refreshToken,
    );

    const firstRotation = await service.refresh(first.refreshToken);
    const secondRotation = await service.refresh(second.refreshToken);
    expect(typeof firstRotation.accessToken).toBe('string');
    expect(typeof secondRotation.accessToken).toBe('string');
  });

  it('rotates a refresh token and rejects reuse of the old token', async () => {
    const initial = await login();
    const rotated = await service.refresh(initial.refreshToken);

    expect(rotated.refreshToken).not.toBe(initial.refreshToken);
    await expect(service.refresh(initial.refreshToken)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('allows only one concurrent rotation for the same token', async () => {
    const initial = await login();
    const results = await Promise.allSettled([
      service.refresh(initial.refreshToken),
      service.refresh(initial.refreshToken),
    ]);

    expect(
      results.filter((value) => value.status === 'fulfilled'),
    ).toHaveLength(1);
    expect(results.filter((value) => value.status === 'rejected')).toHaveLength(
      1,
    );
  });

  it('revokes the server session on logout', async () => {
    const initial = await login();

    await expect(service.logout(initial.refreshToken)).resolves.toEqual({
      message: 'Logged out successfully',
    });
    await expect(service.refresh(initial.refreshToken)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('returns only the safe current-user profile', async () => {
    await expect(service.me(user.id)).resolves.toEqual({
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      company: user.company,
      jobTitle: user.jobTitle,
      city: user.city,
      state: user.state,
      role: user.role,
    });
  });

  function login() {
    return service.login({ email: user.email, password: 'Password123!' });
  }
});

function safeUser(user: FakeUser) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    company: user.company,
    jobTitle: user.jobTitle,
    city: user.city,
    state: user.state,
    role: user.role,
  };
}

function matches(value: FakeSession, where: Record<string, unknown>): boolean {
  if (where.id != null && value.id !== where.id) return false;
  if (where.userId != null && value.userId !== where.userId) return false;
  if (
    where.refreshTokenHash != null &&
    value.refreshTokenHash !== where.refreshTokenHash
  ) {
    return false;
  }
  if (where.revokedAt === null && value.revokedAt !== null) return false;
  const expiry = where.expiresAt as { gt?: Date } | undefined;
  if (expiry?.gt != null && value.expiresAt <= expiry.gt) return false;
  return true;
}
