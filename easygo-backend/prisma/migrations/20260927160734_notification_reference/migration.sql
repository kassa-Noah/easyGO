-- CreateEnum
CREATE TYPE "NotificationReference" AS ENUM ('CONVERSATION', 'BOOKING', 'TRIP', 'PARCEL', 'LUGGAGE', 'AGENCY');

-- AlterTable
ALTER TABLE "Notification" ADD COLUMN     "referenceId" TEXT,
ADD COLUMN     "referenceType" "NotificationReference";
