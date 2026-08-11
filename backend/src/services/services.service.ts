import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { MeasurementUnit, SpaceFitStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateCustomerMachineDto } from './dto/create-customer-machine.dto';
import { CreateMachineScanDto } from './dto/create-machine-scan.dto';
import { CreateServiceRequestDto } from './dto/create-service-request.dto';
import { CreateSpaceAssessmentDto } from './dto/create-space-assessment.dto';

const productSummary = {
  id: true,
  slug: true,
  name: true,
  icon: true,
} as const;

const recommendationDisclaimer =
  'Preliminary automated guidance only. Final machine selection, safety clearances, utilities, floor load and installation access must be verified by a HYWAY engineer after a site assessment.';

type CategoryProfile = {
  name: string;
  slug: string;
  minimumLengthMm: number;
  minimumWidthMm: number;
  minimumHeightMm: number;
};

const categoryProfiles: CategoryProfile[] = [
  {
    name: 'Conveyors',
    slug: 'conveyors',
    minimumLengthMm: 1500,
    minimumWidthMm: 600,
    minimumHeightMm: 900,
  },
  {
    name: 'Mixer',
    slug: 'mixer',
    minimumLengthMm: 1000,
    minimumWidthMm: 800,
    minimumHeightMm: 1400,
  },
  {
    name: 'Washer',
    slug: 'washer',
    minimumLengthMm: 1800,
    minimumWidthMm: 1000,
    minimumHeightMm: 1400,
  },
  {
    name: 'Snacks Machines',
    slug: 'snacks-machines',
    minimumLengthMm: 2200,
    minimumWidthMm: 1000,
    minimumHeightMm: 1600,
  },
];

@Injectable()
export class ServicesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  async createMachine(userId: string, dto: CreateCustomerMachineDto) {
    const name = dto.name.trim();
    const category = this.categoryProfile(dto.category).name;
    const serialNumber = this.optionalText(dto.serialNumber);

    if (serialNumber) {
      const duplicate = await this.prisma.customerMachine.findFirst({
        where: {
          userId,
          serialNumber: { equals: serialNumber, mode: 'insensitive' },
        },
        select: { id: true },
      });
      if (duplicate) {
        throw new ConflictException(
          'A machine with this serial number is already registered',
        );
      }
    }

    const product = await this.findProductForCategory(category);
    return this.prisma.customerMachine.create({
      data: {
        userId,
        name,
        category,
        serialNumber,
        site: this.optionalText(dto.site),
        productId: product?.id,
      },
      include: { product: { select: productSummary } },
    });
  }

  findMachines(userId: string) {
    return this.prisma.customerMachine.findMany({
      where: { userId },
      include: { product: { select: productSummary } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createRequest(userId: string, dto: CreateServiceRequestDto) {
    const machineName = dto.machineName.trim();
    const category = this.categoryProfile(dto.machineCategory).name;
    const customerMachine = await this.prisma.customerMachine.findFirst({
      where: {
        userId,
        name: { equals: machineName, mode: 'insensitive' },
      },
      select: { id: true, productId: true },
    });
    const product = customerMachine?.productId
      ? null
      : await this.findProductForCategory(category);

    const request = await this.prisma.serviceRequest.create({
      data: {
        userId,
        machineName,
        machineCategory: category,
        serviceType: dto.serviceType,
        issueDescription: dto.issueDescription.trim(),
        urgency: dto.urgency,
        preferredVisitAt: dto.preferredVisitAt
          ? new Date(dto.preferredVisitAt)
          : null,
        customerMachineId: customerMachine?.id,
        productId: customerMachine?.productId ?? product?.id,
      },
      include: {
        product: { select: productSummary },
        customerMachine: {
          select: { id: true, name: true, serialNumber: true, site: true },
        },
      },
    });
    const customer = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { name: true, email: true },
    });
    if (customer) {
      void this.notifications.notifyServiceRequestCreated({
        requestId: request.id,
        customerName: customer.name,
        customerEmail: customer.email,
        machineName: request.machineName,
        machineCategory: request.machineCategory,
        serviceType: request.serviceType,
        urgency: request.urgency,
        issueDescription: request.issueDescription,
        preferredVisitAt: request.preferredVisitAt,
      });
    }
    return request;
  }

  findRequests(userId: string) {
    return this.prisma.serviceRequest.findMany({
      where: { userId },
      include: {
        product: { select: productSummary },
        customerMachine: {
          select: { id: true, name: true, serialNumber: true, site: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createScan(userId: string, dto: CreateMachineScanDto) {
    const serialNumber = this.optionalText(dto.serialNumber);
    const machineName = this.optionalText(dto.machineName);
    const notes = this.optionalText(dto.notes);
    if (!serialNumber && !machineName && !notes) {
      throw new BadRequestException(
        'Provide a serial number, machine name or scan note',
      );
    }

    const customerMachine = serialNumber
      ? await this.prisma.customerMachine.findFirst({
          where: {
            userId,
            serialNumber: { equals: serialNumber, mode: 'insensitive' },
          },
          select: { id: true, productId: true, name: true },
        })
      : machineName
        ? await this.prisma.customerMachine.findFirst({
            where: {
              userId,
              name: { equals: machineName, mode: 'insensitive' },
            },
            select: { id: true, productId: true, name: true },
          })
        : null;

    return this.prisma.machineScan.create({
      data: {
        userId,
        serialNumber,
        machineName: machineName ?? customerMachine?.name,
        notes,
        customerMachineId: customerMachine?.id,
        productId: customerMachine?.productId,
      },
      include: {
        product: { select: productSummary },
        customerMachine: {
          select: { id: true, name: true, serialNumber: true, site: true },
        },
      },
    });
  }

  findScans(userId: string) {
    return this.prisma.machineScan.findMany({
      where: { userId },
      include: {
        product: { select: productSummary },
        customerMachine: {
          select: { id: true, name: true, serialNumber: true, site: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createSpaceAssessment(userId: string, dto: CreateSpaceAssessmentDto) {
    const lengthMm = this.toMillimeters(dto.length, dto.unit);
    const widthMm = this.toMillimeters(dto.width, dto.unit);
    const heightMm = this.toMillimeters(dto.height, dto.unit);
    const entryWidthMm = dto.entryWidth
      ? this.toMillimeters(dto.entryWidth, dto.unit)
      : null;
    const entryHeightMm = dto.entryHeight
      ? this.toMillimeters(dto.entryHeight, dto.unit)
      : null;

    if ([lengthMm, widthMm, heightMm].some((value) => value < 100)) {
      throw new BadRequestException(
        'Length, width and height must each be at least 100 mm',
      );
    }

    const profile = this.categoryProfile(dto.machineCategory, dto.material);
    const product = await this.findProductForCategory(profile.name);
    const recommendation = this.calculateRecommendation({
      profile,
      lengthMm,
      widthMm,
      heightMm,
      entryWidthMm,
      entryHeightMm,
      hasSelectionContext: Boolean(
        this.optionalText(dto.machineCategory) ||
        this.optionalText(dto.material),
      ),
      material: this.optionalText(dto.material),
      throughputPerHour: dto.throughputPerHour,
    });

    const assessment = await this.prisma.spaceAssessment.create({
      data: {
        userId,
        inputUnit: dto.unit,
        inputLength: dto.length,
        inputWidth: dto.width,
        inputHeight: dto.height,
        inputEntryWidth: dto.entryWidth,
        inputEntryHeight: dto.entryHeight,
        lengthMm,
        widthMm,
        heightMm,
        entryWidthMm,
        entryHeightMm,
        machineCategory: this.optionalText(dto.machineCategory),
        material: this.optionalText(dto.material),
        throughputPerHour: dto.throughputPerHour,
        fitStatus: recommendation.fitStatus,
        recommendedCategory: profile.name,
        recommendedMachineType: recommendation.recommendedMachineType,
        recommendedMaxLengthMm: recommendation.maximumMachineEnvelopeMm.length,
        recommendedMaxWidthMm: recommendation.maximumMachineEnvelopeMm.width,
        recommendedMaxHeightMm: recommendation.maximumMachineEnvelopeMm.height,
        recommendationSummary: recommendation.summary,
        recommendationDisclaimer,
        productId: product?.id,
      },
      include: { product: { select: productSummary } },
    });

    return { assessment, preliminaryRecommendation: recommendation };
  }

  async findSpaceAssessments(userId: string) {
    const assessments = await this.prisma.spaceAssessment.findMany({
      where: { userId },
      include: { product: { select: productSummary } },
      orderBy: { createdAt: 'desc' },
    });

    return assessments.map((assessment) => ({
      assessment,
      preliminaryRecommendation: {
        fitStatus: assessment.fitStatus,
        recommendedCategory: assessment.recommendedCategory,
        recommendedMachineType: assessment.recommendedMachineType,
        maximumMachineEnvelopeMm: {
          length: assessment.recommendedMaxLengthMm,
          width: assessment.recommendedMaxWidthMm,
          height: assessment.recommendedMaxHeightMm,
        },
        summary: assessment.recommendationSummary,
        disclaimer: assessment.recommendationDisclaimer,
      },
    }));
  }

  private calculateRecommendation(input: {
    profile: CategoryProfile;
    lengthMm: number;
    widthMm: number;
    heightMm: number;
    entryWidthMm: number | null;
    entryHeightMm: number | null;
    hasSelectionContext: boolean;
    material: string | null;
    throughputPerHour?: number;
  }) {
    const sideClearanceMm = 300;
    const overheadClearanceMm = 450;
    const entryClearanceMm = 100;
    const roomWidthLimit = input.widthMm - sideClearanceMm * 2;
    const entryWidthLimit = input.entryWidthMm
      ? input.entryWidthMm - entryClearanceMm * 2
      : roomWidthLimit;
    const roomHeightLimit = input.heightMm - overheadClearanceMm;
    const entryHeightLimit = input.entryHeightMm
      ? input.entryHeightMm - entryClearanceMm
      : roomHeightLimit;
    const maximumMachineEnvelopeMm = {
      length: Math.max(0, input.lengthMm - sideClearanceMm * 2),
      width: Math.max(0, Math.min(roomWidthLimit, entryWidthLimit)),
      height: Math.max(0, Math.min(roomHeightLimit, entryHeightLimit)),
    };

    const hasPositiveEnvelope = Object.values(maximumMachineEnvelopeMm).every(
      (value) => value > 0,
    );
    const meetsMinimumEnvelope =
      maximumMachineEnvelopeMm.length >= input.profile.minimumLengthMm &&
      maximumMachineEnvelopeMm.width >= input.profile.minimumWidthMm &&
      maximumMachineEnvelopeMm.height >= input.profile.minimumHeightMm;

    let fitStatus: SpaceFitStatus;
    let summary: string;
    if (!hasPositiveEnvelope) {
      fitStatus = SpaceFitStatus.NOT_FEASIBLE;
      summary =
        'The measured space or entry does not leave a positive machine envelope after preliminary safety clearances.';
    } else if (!meetsMinimumEnvelope) {
      fitStatus = SpaceFitStatus.LIMITED_FIT;
      summary = `The usable envelope is below the preliminary ${input.profile.name} planning baseline. A compact or custom solution needs engineering review.`;
    } else if (!input.hasSelectionContext) {
      fitStatus = SpaceFitStatus.EXPERT_REVIEW_REQUIRED;
      summary =
        'The space can hold a preliminary industrial-machine envelope, but material or machine category is required before selecting a solution.';
    } else {
      fitStatus = SpaceFitStatus.EXPERT_REVIEW_REQUIRED;
      summary = `The space can support a preliminary ${input.profile.name} shortlist, but the current catalogue has no certified model dimensions. A HYWAY engineer must select and verify the exact model.`;
    }

    if (input.throughputPerHour) {
      summary += ` The requested throughput of ${input.throughputPerHour} units/hour must be validated against the selected machine model.`;
    }

    return {
      fitStatus,
      recommendedCategory: input.profile.name,
      recommendedMachineType: this.machineTypeFor(
        input.profile,
        input.material,
      ),
      maximumMachineEnvelopeMm,
      summary,
      disclaimer: recommendationDisclaimer,
    };
  }

  private machineTypeFor(
    profile: CategoryProfile,
    material: string | null,
  ): string {
    const search = material?.toLowerCase() ?? '';
    if (profile.slug === 'washer') {
      if (search.includes('crate')) return 'Crate Washer';
      if (search.includes('pallet')) return 'Pallet Washer';
      return 'Industrial Washer';
    }
    if (profile.slug === 'mixer') return 'Industrial Mixer / Blender';
    if (profile.slug === 'snacks-machines') {
      if (/fry|chips|potato/.test(search)) return 'Industrial Fryer';
      if (/flavou?r|season/.test(search)) return 'Flavoring Drum';
      if (/grad|sort/.test(search)) return 'Grading Machine';
      if (/inspect|quality/.test(search)) return 'Inspection System';
      return 'Snack Processing Machine';
    }
    return 'Compact Conveyor System';
  }

  private categoryProfile(
    category?: string,
    material?: string,
  ): CategoryProfile {
    const search = `${category ?? ''} ${material ?? ''}`.trim().toLowerCase();
    if (/wash|crate|pallet|clean/.test(search)) return categoryProfiles[2];
    if (/mix|blend|powder|spice|flour|masala/.test(search)) {
      return categoryProfiles[1];
    }
    if (/snack|chips|namkeen|fry|flavou?r|grad|inspect|potato/.test(search)) {
      return categoryProfiles[3];
    }
    return categoryProfiles[0];
  }

  private async findProductForCategory(category: string) {
    const profile = this.categoryProfile(category);
    return this.prisma.product.findFirst({
      where: {
        isActive: true,
        OR: [
          { slug: profile.slug },
          { name: { equals: profile.name, mode: 'insensitive' } },
        ],
      },
      select: { id: true },
    });
  }

  private toMillimeters(value: number, unit: MeasurementUnit): number {
    const multiplier = unit === MeasurementUnit.FT ? 304.8 : 1;
    return Math.round(value * multiplier);
  }

  private optionalText(value?: string): string | null {
    const normalized = value?.trim();
    return normalized ? normalized : null;
  }
}
