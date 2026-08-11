import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { MeasurementUnit } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

const uppercase = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim().toUpperCase() : value;

export class CreateSpaceAssessmentDto {
  @ApiProperty({ enum: MeasurementUnit, example: MeasurementUnit.FT })
  @Transform(uppercase)
  @IsEnum(MeasurementUnit)
  unit!: MeasurementUnit;

  @ApiProperty({ example: 20, description: 'Space length in the chosen unit' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @Min(0.001)
  @Max(10_000_000)
  length!: number;

  @ApiProperty({ example: 12.5, description: 'Space width in the chosen unit' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @Min(0.001)
  @Max(10_000_000)
  width!: number;

  @ApiProperty({ example: 10, description: 'Space height in the chosen unit' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @Min(0.001)
  @Max(10_000_000)
  height!: number;

  @ApiPropertyOptional({ description: 'Entry width in the chosen unit' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @Min(0.001)
  @Max(10_000_000)
  entryWidth?: number;

  @ApiPropertyOptional({ description: 'Entry height in the chosen unit' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @Min(0.001)
  @Max(10_000_000)
  entryHeight?: number;

  @ApiPropertyOptional({ example: 'Conveyors' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  machineCategory?: string;

  @ApiPropertyOptional({ example: 'Packed cartons' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  material?: string;

  @ApiPropertyOptional({ example: 1200 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(10_000_000)
  throughputPerHour?: number;
}
