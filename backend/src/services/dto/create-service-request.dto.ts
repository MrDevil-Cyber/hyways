import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ServiceType, ServiceUrgency } from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';

const uppercase = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim().toUpperCase() : value;

export class CreateServiceRequestDto {
  @ApiProperty({ example: 'Packing Line Conveyor' })
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  machineName!: string;

  @ApiProperty({ example: 'Conveyors' })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  machineCategory!: string;

  @ApiProperty({ enum: ServiceType, example: ServiceType.MAINTENANCE })
  @Transform(uppercase)
  @IsEnum(ServiceType)
  serviceType!: ServiceType;

  @ApiProperty({
    example: 'The drive is making an unusual noise during operation.',
  })
  @IsString()
  @MinLength(10)
  @MaxLength(2000)
  issueDescription!: string;

  @ApiProperty({ enum: ServiceUrgency, default: ServiceUrgency.NORMAL })
  @Transform(uppercase)
  @IsEnum(ServiceUrgency)
  urgency!: ServiceUrgency;

  @ApiPropertyOptional({ example: '2026-08-10T09:00:00.000Z' })
  @IsOptional()
  @IsDateString()
  preferredVisitAt?: string;
}
