import { BadRequestException } from '@nestjs/common';
import { MeasurementUnit, SpaceFitStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ServicesService } from './services.service';

describe('ServicesService', () => {
  it('normalizes feet to millimetres and persists its recommendation', async () => {
    const create = jest.fn(({ data }: { data: Record<string, unknown> }) =>
      Promise.resolve({ id: 'assessment-1', ...data, product: null }),
    );
    const prisma = {
      product: {
        findFirst: jest.fn().mockResolvedValue({ id: 'product-1' }),
      },
      spaceAssessment: { create },
    } as unknown as PrismaService;
    const service = new ServicesService(prisma);

    const result = await service.createSpaceAssessment('user-1', {
      unit: MeasurementUnit.FT,
      length: 20,
      width: 12.5,
      height: 10,
      entryWidth: 8,
      entryHeight: 9,
      machineCategory: 'Conveyors',
      material: 'Packed cartons',
      throughputPerHour: 1200,
    });

    expect(create.mock.calls[0][0].data).toMatchObject({
      userId: 'user-1',
      lengthMm: 6096,
      widthMm: 3810,
      heightMm: 3048,
      entryWidthMm: 2438,
      entryHeightMm: 2743,
      fitStatus: SpaceFitStatus.EXPERT_REVIEW_REQUIRED,
      recommendedMaxLengthMm: 5496,
      recommendedMaxWidthMm: 2238,
      recommendedMaxHeightMm: 2598,
    });
    expect(result.preliminaryRecommendation).toMatchObject({
      fitStatus: SpaceFitStatus.EXPERT_REVIEW_REQUIRED,
      recommendedCategory: 'Conveyors',
      recommendedMachineType: 'Compact Conveyor System',
      maximumMachineEnvelopeMm: {
        length: 5496,
        width: 2238,
        height: 2598,
      },
    });
    expect(result.preliminaryRecommendation.disclaimer).toContain(
      'Preliminary automated guidance only',
    );
  });

  it('always scopes machine lists to the authenticated user', async () => {
    const findMany = jest.fn().mockResolvedValue([]);
    const prisma = {
      customerMachine: { findMany },
    } as unknown as PrismaService;
    const service = new ServicesService(prisma);

    await service.findMachines('user-42');

    expect(findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: { userId: 'user-42' } }),
    );
  });

  it('rejects an empty machine scan submission', async () => {
    const service = new ServicesService({} as PrismaService);

    await expect(
      service.createScan('user-1', {
        serialNumber: ' ',
        machineName: '',
        notes: '  ',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
