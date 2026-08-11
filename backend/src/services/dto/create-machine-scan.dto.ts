import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateMachineScanDto {
  @ApiPropertyOptional({ example: 'HY-12345' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  serialNumber?: string;

  @ApiPropertyOptional({ example: 'Packing Line Conveyor' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  machineName?: string;

  @ApiPropertyOptional({
    example: 'Nameplate is damaged; please help identify this machine.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}
