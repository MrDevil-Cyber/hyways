import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateCustomerMachineDto } from './dto/create-customer-machine.dto';
import { CreateMachineScanDto } from './dto/create-machine-scan.dto';
import { CreateServiceRequestDto } from './dto/create-service-request.dto';
import { CreateSpaceAssessmentDto } from './dto/create-space-assessment.dto';
import { ServicesService } from './services.service';

@ApiTags('Services')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('services')
export class ServicesController {
  constructor(private readonly services: ServicesService) {}

  @ApiOperation({ summary: 'Register a machine owned by the current user' })
  @Post('machines')
  createMachine(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateCustomerMachineDto,
  ) {
    return this.services.createMachine(user.sub, dto);
  }

  @ApiOperation({ summary: "List the current user's registered machines" })
  @Get('machines')
  findMachines(@CurrentUser() user: AuthUser) {
    return this.services.findMachines(user.sub);
  }

  @ApiOperation({ summary: 'Create an authenticated machine service request' })
  @Post('requests')
  createRequest(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateServiceRequestDto,
  ) {
    return this.services.createRequest(user.sub, dto);
  }

  @ApiOperation({ summary: "List the current user's service requests" })
  @Get('requests')
  findRequests(@CurrentUser() user: AuthUser) {
    return this.services.findRequests(user.sub);
  }

  @ApiOperation({ summary: 'Submit machine information for scanning/review' })
  @Post('scans')
  createScan(@CurrentUser() user: AuthUser, @Body() dto: CreateMachineScanDto) {
    return this.services.createScan(user.sub, dto);
  }

  @ApiOperation({ summary: "List the current user's machine scans" })
  @Get('scans')
  findScans(@CurrentUser() user: AuthUser) {
    return this.services.findScans(user.sub);
  }

  @ApiOperation({
    summary: 'Assess a space and persist a preliminary machine recommendation',
  })
  @Post('space-assessments')
  createSpaceAssessment(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateSpaceAssessmentDto,
  ) {
    return this.services.createSpaceAssessment(user.sub, dto);
  }

  @ApiOperation({ summary: "List the current user's space assessments" })
  @Get('space-assessments')
  findSpaceAssessments(@CurrentUser() user: AuthUser) {
    return this.services.findSpaceAssessments(user.sub);
  }
}
