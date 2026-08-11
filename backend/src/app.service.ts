import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHealth() {
    return {
      status: 'ok',
      service: 'hyway-api',
      timestamp: new Date().toISOString(),
    };
  }
}
