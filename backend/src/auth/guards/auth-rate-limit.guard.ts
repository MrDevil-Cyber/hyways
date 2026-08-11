import {
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { Request } from 'express';

type LimitConfig = {
  limit: number;
  windowMs: number;
};

type Bucket = {
  count: number;
  expiresAt: number;
};

export const AUTH_RATE_LIMIT_KEY = 'auth-rate-limit';

const defaultLimits: Record<string, LimitConfig> = {
  login: { limit: 5, windowMs: 60_000 },
  register: { limit: 3, windowMs: 10 * 60_000 },
  refresh: { limit: 20, windowMs: 60_000 },
  logout: { limit: 20, windowMs: 60_000 },
};

const buckets = new Map<string, Bucket>();

@Injectable()
export class AuthRateLimitGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const limitConfig = this.reflector.getAllAndOverride<LimitConfig>(
      AUTH_RATE_LIMIT_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!limitConfig) return true;

    const request = context.switchToHttp().getRequest<Request>();
    const key = `${this.getClientIp(request)}:${request.method}:${request.path}`;
    const now = Date.now();
    const bucket = buckets.get(key);
    if (!bucket || bucket.expiresAt <= now) {
      buckets.set(key, { count: 1, expiresAt: now + limitConfig.windowMs });
      return true;
    }

    if (bucket.count >= limitConfig.limit) {
      const retryAfterSeconds = Math.ceil((bucket.expiresAt - now) / 1000);
      throw new HttpException(
        `Too many requests. Try again in ${retryAfterSeconds} seconds.`,
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    bucket.count += 1;
    return true;
  }

  static routeLimit(name: keyof typeof defaultLimits): LimitConfig {
    return defaultLimits[name];
  }

  private getClientIp(request: Request): string {
    const forwardedFor = request.headers['x-forwarded-for'];
    if (typeof forwardedFor === 'string' && forwardedFor.trim()) {
      return forwardedFor.split(',')[0].trim();
    }
    return request.ip || request.socket.remoteAddress || 'unknown';
  }
}

export const AuthRateLimit = (name: keyof typeof defaultLimits) =>
  SetMetadata(AUTH_RATE_LIMIT_KEY, defaultLimits[name]);
