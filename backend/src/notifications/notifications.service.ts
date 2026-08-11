import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

type ServiceRequestNotification = {
  requestId: string;
  customerName: string;
  customerEmail: string;
  machineName: string;
  machineCategory: string;
  serviceType: string;
  urgency: string;
  issueDescription: string;
  preferredVisitAt: Date | null;
};

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private readonly config: ConfigService) {}

  async notifyServiceRequestCreated(request: ServiceRequestNotification) {
    const preferredVisit = request.preferredVisitAt
      ? request.preferredVisitAt.toLocaleDateString('en-IN', {
          day: 'numeric',
          month: 'short',
          year: 'numeric',
        })
      : 'Not requested';
    const details = [
      `Request ID: ${request.requestId}`,
      `Customer: ${request.customerName} (${request.customerEmail})`,
      `Machine: ${request.machineName} — ${request.machineCategory}`,
      `Service: ${request.serviceType}`,
      `Urgency: ${request.urgency}`,
      `Preferred visit: ${preferredVisit}`,
      `Issue: ${request.issueDescription}`,
    ].join('\n');

    await Promise.allSettled([
      this.sendCustomerConfirmation(request, preferredVisit),
      this.sendTeamEmail(`New HYWAY service request: ${request.machineName}`, details),
      this.sendTeamWhatsApp(request),
    ]);
  }

  private async sendCustomerConfirmation(
    request: ServiceRequestNotification,
    preferredVisit: string,
  ) {
    const text = [
      `Hi ${request.customerName},`,
      '',
      'Your HYWAY service request has been received.',
      `Request ID: ${request.requestId}`,
      `Machine: ${request.machineName}`,
      `Service: ${request.serviceType}`,
      `Preferred visit: ${preferredVisit}`,
      '',
      'Our service team will review the details and contact you with the next step.',
    ].join('\n');
    await this.sendEmail(
      request.customerEmail,
      `HYWAY service request received — ${request.requestId}`,
      text,
    );
  }

  private async sendTeamEmail(subject: string, text: string) {
    const recipients = this.csv('SERVICE_TEAM_EMAILS');
    await Promise.all(recipients.map((recipient) => this.sendEmail(recipient, subject, text)));
  }

  private async sendEmail(to: string, subject: string, text: string) {
    const apiKey = this.config.get<string>('RESEND_API_KEY');
    const from = this.config.get<string>('EMAIL_FROM');
    if (!apiKey || !from) {
      this.logger.debug(`Email notification skipped for ${to}: Resend is not configured.`);
      return;
    }

    try {
      const response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ from, to: [to], subject, text }),
      });
      if (!response.ok) {
        this.logger.error(`Email notification failed for ${to}: ${await response.text()}`);
      }
    } catch (error) {
      this.logger.error(`Email notification failed for ${to}`, error);
    }
  }

  private async sendTeamWhatsApp(request: ServiceRequestNotification) {
    const accessToken = this.config.get<string>('WHATSAPP_ACCESS_TOKEN');
    const phoneNumberId = this.config.get<string>('WHATSAPP_PHONE_NUMBER_ID');
    const templateName = this.config.get<string>('WHATSAPP_SERVICE_TEMPLATE');
    const recipients = this.csv('SERVICE_TEAM_WHATSAPP_NUMBERS');
    if (!accessToken || !phoneNumberId || !templateName || recipients.length === 0) {
      this.logger.debug('Team WhatsApp notification skipped: Meta WhatsApp is not configured.');
      return;
    }

    const parameters = [
      request.requestId,
      request.customerName,
      request.machineName,
      request.serviceType,
      request.urgency,
      request.issueDescription,
    ].map((text) => ({ type: 'text', text }));

    await Promise.all(
      recipients.map(async (to) => {
        try {
          const response = await fetch(
            `https://graph.facebook.com/v21.0/${phoneNumberId}/messages`,
            {
              method: 'POST',
              headers: {
                Authorization: `Bearer ${accessToken}`,
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({
                messaging_product: 'whatsapp',
                to,
                type: 'template',
                template: {
                  name: templateName,
                  language: { code: 'en' },
                  components: [
                    {
                      type: 'body',
                      parameters,
                    },
                  ],
                },
              }),
            },
          );
          if (!response.ok) {
            this.logger.error(
              `WhatsApp notification failed for ${to}: ${await response.text()}`,
            );
          }
        } catch (error) {
          this.logger.error(`WhatsApp notification failed for ${to}`, error);
        }
      }),
    );
  }

  private csv(key: string) {
    return this.config
      .get<string>(key, '')
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean);
  }
}
