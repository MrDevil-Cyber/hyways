import { Injectable, NotFoundException } from '@nestjs/common';
import { InquiryStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInquiryDto } from './dto/create-inquiry.dto';

@Injectable()
export class InquiriesService {
  constructor(private readonly prisma: PrismaService) {}

  create(dto: CreateInquiryDto, userId?: string) {
    return this.prisma.inquiry.create({
      data: {
        ...dto,
        email: dto.email.trim().toLowerCase(),
        userId,
      },
      include: { product: { select: { id: true, name: true, slug: true } } },
    });
  }

  findAll(status?: InquiryStatus) {
    return this.prisma.inquiry.findMany({
      where: status ? { status } : undefined,
      include: {
        product: { select: { id: true, name: true, slug: true } },
        user: { select: { id: true, name: true, email: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateStatus(id: string, status: InquiryStatus) {
    const exists = await this.prisma.inquiry.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException('Inquiry not found');
    return this.prisma.inquiry.update({ where: { id }, data: { status } });
  }
}
