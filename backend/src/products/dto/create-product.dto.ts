import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  IsUrl,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class ProductImageDto {
  @ApiProperty({ example: 'https://cdn.example.com/product.png' })
  @IsUrl({ require_tld: false })
  url!: string;

  @ApiProperty({ example: 'Vertical conveyor front view' })
  @IsString()
  @MinLength(2)
  altText!: string;

  @ApiProperty({ default: 0 })
  @IsInt()
  @Min(0)
  sortOrder = 0;
}

export class CreateProductDto {
  @ApiProperty({ example: 'vertical-conveyor' })
  @IsString()
  @MinLength(2)
  slug!: string;

  @ApiProperty({ example: 'Vertical Conveyor' })
  @IsString()
  @MinLength(2)
  name!: string;

  @ApiProperty()
  @IsString()
  @MinLength(5)
  shortDescription!: string;

  @ApiProperty()
  @IsString()
  @MinLength(10)
  description!: string;

  @ApiProperty({ example: 'unfold_more' })
  @IsString()
  icon!: string;

  @ApiProperty({ default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean = true;

  @ApiProperty({ default: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number = 0;

  @ApiProperty({ type: [ProductImageDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ProductImageDto)
  images!: ProductImageDto[];
}
