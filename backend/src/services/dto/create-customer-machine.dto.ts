import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateCustomerMachineDto {
  @ApiProperty({ example: 'Packing Line Conveyor' })
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  name!: string;

  @ApiProperty({ example: 'Conveyors' })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  category!: string;

  @ApiPropertyOptional({ example: 'HY-12345' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  serialNumber?: string;

  @ApiPropertyOptional({ example: 'Faridabad Plant - Line 2' })
  @IsOptional()
  @IsString()
  @MaxLength(180)
  site?: string;
}
