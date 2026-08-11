-- CreateEnum
CREATE TYPE "ServiceType" AS ENUM ('REPAIR', 'MAINTENANCE', 'INSTALLATION', 'INSPECTION', 'CONSULTATION');

-- CreateEnum
CREATE TYPE "ServiceUrgency" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "ServiceRequestStatus" AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "MachineScanStatus" AS ENUM ('SUBMITTED', 'PROCESSING', 'COMPLETED', 'NEEDS_REVIEW');

-- CreateEnum
CREATE TYPE "MeasurementUnit" AS ENUM ('MM', 'FT');

-- CreateEnum
CREATE TYPE "SpaceFitStatus" AS ENUM ('PRELIMINARY_FIT', 'LIMITED_FIT', 'NOT_FEASIBLE', 'EXPERT_REVIEW_REQUIRED');

-- CreateTable
CREATE TABLE "CustomerMachine" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "serialNumber" TEXT,
    "site" TEXT,
    "userId" TEXT NOT NULL,
    "productId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CustomerMachine_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ServiceRequest" (
    "id" TEXT NOT NULL,
    "machineName" TEXT NOT NULL,
    "machineCategory" TEXT NOT NULL,
    "serviceType" "ServiceType" NOT NULL,
    "issueDescription" TEXT NOT NULL,
    "urgency" "ServiceUrgency" NOT NULL DEFAULT 'NORMAL',
    "status" "ServiceRequestStatus" NOT NULL DEFAULT 'SUBMITTED',
    "preferredVisitAt" TIMESTAMP(3),
    "userId" TEXT NOT NULL,
    "productId" TEXT,
    "customerMachineId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ServiceRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MachineScan" (
    "id" TEXT NOT NULL,
    "serialNumber" TEXT,
    "machineName" TEXT,
    "notes" TEXT,
    "status" "MachineScanStatus" NOT NULL DEFAULT 'SUBMITTED',
    "resultSummary" TEXT,
    "userId" TEXT NOT NULL,
    "productId" TEXT,
    "customerMachineId" TEXT,
    "serviceRequestId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MachineScan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SpaceAssessment" (
    "id" TEXT NOT NULL,
    "inputUnit" "MeasurementUnit" NOT NULL,
    "inputLength" DOUBLE PRECISION NOT NULL,
    "inputWidth" DOUBLE PRECISION NOT NULL,
    "inputHeight" DOUBLE PRECISION NOT NULL,
    "inputEntryWidth" DOUBLE PRECISION,
    "inputEntryHeight" DOUBLE PRECISION,
    "lengthMm" INTEGER NOT NULL,
    "widthMm" INTEGER NOT NULL,
    "heightMm" INTEGER NOT NULL,
    "entryWidthMm" INTEGER,
    "entryHeightMm" INTEGER,
    "machineCategory" TEXT,
    "material" TEXT,
    "throughputPerHour" INTEGER,
    "fitStatus" "SpaceFitStatus" NOT NULL,
    "recommendedCategory" TEXT NOT NULL,
    "recommendedMachineType" TEXT NOT NULL,
    "recommendedMaxLengthMm" INTEGER NOT NULL,
    "recommendedMaxWidthMm" INTEGER NOT NULL,
    "recommendedMaxHeightMm" INTEGER NOT NULL,
    "recommendationSummary" TEXT NOT NULL,
    "recommendationDisclaimer" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "productId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SpaceAssessment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CustomerMachine_userId_createdAt_idx" ON "CustomerMachine"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "CustomerMachine_userId_serialNumber_idx" ON "CustomerMachine"("userId", "serialNumber");

-- CreateIndex
CREATE INDEX "CustomerMachine_productId_idx" ON "CustomerMachine"("productId");

-- CreateIndex
CREATE INDEX "ServiceRequest_userId_createdAt_idx" ON "ServiceRequest"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "ServiceRequest_userId_status_idx" ON "ServiceRequest"("userId", "status");

-- CreateIndex
CREATE INDEX "ServiceRequest_productId_idx" ON "ServiceRequest"("productId");

-- CreateIndex
CREATE INDEX "ServiceRequest_customerMachineId_idx" ON "ServiceRequest"("customerMachineId");

-- CreateIndex
CREATE INDEX "MachineScan_userId_createdAt_idx" ON "MachineScan"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "MachineScan_userId_status_idx" ON "MachineScan"("userId", "status");

-- CreateIndex
CREATE INDEX "MachineScan_productId_idx" ON "MachineScan"("productId");

-- CreateIndex
CREATE INDEX "MachineScan_customerMachineId_idx" ON "MachineScan"("customerMachineId");

-- CreateIndex
CREATE INDEX "MachineScan_serviceRequestId_idx" ON "MachineScan"("serviceRequestId");

-- CreateIndex
CREATE INDEX "SpaceAssessment_userId_createdAt_idx" ON "SpaceAssessment"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "SpaceAssessment_userId_fitStatus_idx" ON "SpaceAssessment"("userId", "fitStatus");

-- CreateIndex
CREATE INDEX "SpaceAssessment_productId_idx" ON "SpaceAssessment"("productId");

-- AddForeignKey
ALTER TABLE "CustomerMachine" ADD CONSTRAINT "CustomerMachine_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CustomerMachine" ADD CONSTRAINT "CustomerMachine_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ServiceRequest" ADD CONSTRAINT "ServiceRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ServiceRequest" ADD CONSTRAINT "ServiceRequest_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ServiceRequest" ADD CONSTRAINT "ServiceRequest_customerMachineId_fkey" FOREIGN KEY ("customerMachineId") REFERENCES "CustomerMachine"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MachineScan" ADD CONSTRAINT "MachineScan_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MachineScan" ADD CONSTRAINT "MachineScan_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MachineScan" ADD CONSTRAINT "MachineScan_customerMachineId_fkey" FOREIGN KEY ("customerMachineId") REFERENCES "CustomerMachine"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MachineScan" ADD CONSTRAINT "MachineScan_serviceRequestId_fkey" FOREIGN KEY ("serviceRequestId") REFERENCES "ServiceRequest"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SpaceAssessment" ADD CONSTRAINT "SpaceAssessment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SpaceAssessment" ADD CONSTRAINT "SpaceAssessment_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;
