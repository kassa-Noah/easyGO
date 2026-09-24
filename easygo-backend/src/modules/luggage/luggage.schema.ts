import { z } from "zod";

export const createLuggageSchema = z.object({
  bookingId: z
    .string()
    .uuid("Invalid booking ID"),

  description: z
    .string()
    .trim()
    .max(500)
    .optional(),

  weightKg: z
    .number()
    .positive(
      "Weight must be greater than zero"
    )
    .max(
      100,
      "Weight cannot exceed 100 kg"
    )
    .optional(),
});

export const updateLuggageStatusSchema =
  z.object({
    status: z.enum([
      "RECEIVED_AT_AGENCY",
      "LOADED",
      "IN_TRANSIT",
      "ARRIVED_AT_DESTINATION_AGENCY",
      "READY_FOR_COLLECTION",
      "DELIVERED",
      "LOST",
    ]),

    location: z
      .string()
      .trim()
      .max(200)
      .optional(),

    description: z
      .string()
      .trim()
      .max(500)
      .optional(),
  });