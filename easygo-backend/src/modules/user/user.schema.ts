import { z } from "zod";

export const updateProfileSchema = z.object({
  firstName: z.string().min(2).optional(),
  lastName: z.string().min(2).optional(),
  phone: z.string().min(8).optional(),
});

export const updateUserStatusSchema = z.object({
  isActive: z.boolean(),
});