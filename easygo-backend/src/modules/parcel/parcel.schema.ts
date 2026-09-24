import { z } from "zod";

export const createParcelSchema = z.object({
  description: z
    .string()
    .trim()
    .min(
      2,
      "Parcel description is required"
    )
    .max(
      500,
      "Parcel description cannot exceed 500 characters"
    ),

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

  recipientName: z
    .string()
    .trim()
    .min(
      2,
      "Recipient name is required"
    )
    .max(
      100,
      "Recipient name cannot exceed 100 characters"
    ),

  recipientPhone: z
    .string()
    .trim()
    .min(
      6,
      "Recipient phone is required"
    )
    .max(
      30,
      "Recipient phone cannot exceed 30 characters"
    ),

  originBranchId: z
    .string()
    .uuid(
      "Invalid origin branch ID"
    ),

  destinationBranchId: z
    .string()
    .uuid(
      "Invalid destination branch ID"
    ),

  recipientUserId: z
    .string()
    .uuid(
      "Invalid recipient user ID"
    )
    .optional(),

  tripId: z
    .string()
    .uuid(
      "Invalid trip ID"
    )
    .optional(),
});

export const updateParcelStatusSchema =
  z.object({
    status: z.enum([
      "RECEIVED_AT_ORIGIN_AGENCY",
      "LOADED",
      "IN_TRANSIT",
      "ARRIVED_AT_DESTINATION_AGENCY",
      "READY_FOR_COLLECTION",
      "COLLECTED",
      "DELIVERED",
      "LOST",
      "CANCELLED",
    ]),

    location: z
      .string()
      .trim()
      .max(
        200,
        "Location cannot exceed 200 characters"
      )
      .optional(),

    description: z
      .string()
      .trim()
      .max(
        500,
        "Description cannot exceed 500 characters"
      )
      .optional(),
  });