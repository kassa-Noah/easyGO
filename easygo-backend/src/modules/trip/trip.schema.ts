import { z } from "zod";

export const createTripSchema = z.object({
  departureTime: z.string().datetime(),
  arrivalTime: z.string().datetime().optional(),

  price: z.number().positive("Price must be greater than 0"),

  totalSeats: z
    .number()
    .int()
    .positive("Total seats must be greater than 0"),

  agencyId: z.string().uuid("Invalid agency ID"),
  routeId: z.string().uuid("Invalid route ID"),
  vehicleId: z.string().uuid("Invalid vehicle ID").optional(),
});

export const updateTripSchema = z.object({
  departureTime: z.string().datetime().optional(),
  arrivalTime: z.string().datetime().optional(),

  price: z.number().positive().optional(),

  totalSeats: z.number().int().positive().optional(),

  vehicleId: z.string().uuid().nullable().optional(),

  status: z
    .enum([
      "SCHEDULED",
      "BOARDING",
      "DEPARTED",
      "ARRIVED",
      "CANCELLED",
    ])
    .optional(),
});