import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, Matches, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'Amit Kumar' })
  @IsString()
  @MinLength(2)
  name!: string;

  @ApiProperty({ example: 'amit@example.com' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: '+91 98765 43210' })
  @IsString()
  @Matches(/^[0-9+()\-\s]{7,20}$/)
  phone!: string;

  @ApiProperty({ example: 'Acme Foods Pvt. Ltd.' })
  @IsString()
  @MinLength(2)
  company!: string;

  @ApiProperty({ example: 'Plant Manager' })
  @IsString()
  @MinLength(2)
  jobTitle!: string;

  @ApiProperty({ example: 'Pune' })
  @IsString()
  @MinLength(2)
  city!: string;

  @ApiProperty({ example: 'Maharashtra' })
  @IsString()
  @MinLength(2)
  state!: string;

  @ApiProperty({ example: 'StrongPassword123!' })
  @IsString()
  @MinLength(8)
  password!: string;
}
