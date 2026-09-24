import { z } from "zod";

export const assignTaxiSchema = z.object({
  providerId: z
    .string()
    .uuid("Invalid taxi provider ID"),

  segmentType: z.enum([
    "HOME_TO_DEPARTURE_AGENCY",
    "ARRIVAL_AGENCY_TO_DESTINATION",
  ]),

  estimatedFare: z
    .number()
    .nonnegative(
      "Estimated fare cannot be negative"
    )
    .optional(),
});

export const updateTaxiAssignmentSchema = z
  .object({
    status: z
      .enum([
        "PENDING",
        "DRIVER_ASSIGNED",
        "DRIVER_ARRIVING",
        "PASSENGER_PICKED_UP",
        "COMPLETED",
        "CANCELLED",
      ])
      .optional(),

    driverName: z
      .string()
      .trim()
      .min(
        2,
        "Driver name must contain at least 2 characters"
      )
      .optional(),

    driverPhone: z
      .string()
      .trim()
      .min(
        6,
        "Invalid driver phone number"
      )
      .optional(),

    vehicleRegistration: z
      .string()
      .trim()
      .min(
        2,
        "Invalid vehicle registration"
      )
      .optional(),

    vehicleDescription: z
      .string()
      .trim()
      .min(
        2,
        "Invalid vehicle description"
      )
      .optional(),

    externalReference: z
      .string()
      .trim()
      .min(
        1,
        "Invalid external reference"
      )
      .optional(),

    finalFare: z
      .number()
      .nonnegative(
        "Final fare cannot be negative"
      )
      .optional(),
  })
  .refine(
    (data) =>
      Object.values(data).some(
        (value) => value !== undefined
      ),
    {
      message:
        "At least one field must be provided",
    }
  );