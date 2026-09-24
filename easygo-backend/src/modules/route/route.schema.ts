import { z } from "zod";

export const createRouteSchema = z.object({
  originBranchId: z.string().uuid("Invalid origin branch ID"),
  destinationBranchId: z.string().uuid("Invalid destination branch ID"),
  distanceKm: z.number().positive("Distance must be greater than 0").optional(),
  estimatedDurationMinutes: z
    .number()
    .int()
    .positive("Estimated duration must be greater than 0")
    .optional(),
  baseFare: z.number().positive("Base fare must be greater than 0"),
});

export const updateRouteSchema = z.object({
  originBranchId: z.string().uuid().optional(),
  destinationBranchId: z.string().uuid().optional(),
  distanceKm: z.number().positive().optional(),
  estimatedDurationMinutes: z.number().int().positive().optional(),
  baseFare: z.number().positive().optional(),
  isActive: z.boolean().optional(),
});