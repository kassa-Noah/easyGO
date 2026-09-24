import { z } from "zod";

export const searchTripsSchema = z.object({
  originCity: z
    .string()
    .min(2, "Origin city is required"),

  destinationCity: z
    .string()
    .min(2, "Destination city is required"),

  travelDate: z
    .string()
    .regex(
      /^\d{4}-\d{2}-\d{2}$/,
      "Travel date must use YYYY-MM-DD format"
    ),

  agencyId: z
    .string()
    .uuid("Invalid agency ID")
    .optional(),
});