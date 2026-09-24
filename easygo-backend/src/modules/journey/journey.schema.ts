import { z } from "zod";

export const createJourneySchema = z.object({
  bookingId: z
    .string()
    .uuid("Invalid booking ID"),

  pickupAddress: z
    .string()
    .trim()
    .min(
      5,
      "Pickup address must contain at least 5 characters"
    )
    .max(
      255,
      "Pickup address cannot exceed 255 characters"
    ),

  pickupLatitude: z
    .number()
    .min(-90, "Invalid pickup latitude")
    .max(90, "Invalid pickup latitude")
    .optional(),

  pickupLongitude: z
    .number()
    .min(-180, "Invalid pickup longitude")
    .max(180, "Invalid pickup longitude")
    .optional(),

  destinationAddress: z
    .string()
    .trim()
    .min(
      5,
      "Destination address must contain at least 5 characters"
    )
    .max(
      255,
      "Destination address cannot exceed 255 characters"
    ),

  destinationLatitude: z
    .number()
    .min(-90, "Invalid destination latitude")
    .max(90, "Invalid destination latitude")
    .optional(),

  destinationLongitude: z
    .number()
    .min(-180, "Invalid destination longitude")
    .max(180, "Invalid destination longitude")
    .optional(),
});

export const updateJourneyStatusSchema = z.object({
  status: z.enum([
    "PENDING",
    "CONFIRMED",
    "PICKUP_ASSIGNED",
    "PICKUP_IN_PROGRESS",
    "AT_DEPARTURE_AGENCY",
    "INTERURBAN_IN_PROGRESS",
    "AT_ARRIVAL_AGENCY",
    "DROPOFF_ASSIGNED",
    "DROPOFF_IN_PROGRESS",
    "COMPLETED",
    "CANCELLED",
  ]),
});