import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';

export class CreateInquiryDto {
  @ApiProperty({ example: 'Amit Kumar' })
  @IsString()
  @MinLength(2)
  name!: string;

  @ApiProperty({ example: 'amit@example.com' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: '+919876543210' })
  @IsString()
  @MinLength(8)
  phone!: string;

  @ApiPropertyOptional({ example: 'Example Industries' })
  @IsOptional()
  @IsString()
  company?: string;

  @ApiProperty({ example: 'Please share a quote and installation timeline.' })
  @IsString()
  @MinLength(10)
  message!: string;

  @ApiPropertyOptional({ description: 'Product ID related to the inquiry' })
  @IsOptional()
  @IsString()
  productId?: string;
}
