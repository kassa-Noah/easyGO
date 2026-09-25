import { z } from "zod";

export const startConversationSchema = z.object({
  agencyId: z.string().uuid("Invalid agency ID"),

  contextType: z
    .enum(["BOOKING", "PARCEL", "GENERAL"])
    .optional(),

  contextReference: z.string().max(60).optional(),

  message: z
    .string()
    .min(1, "The message cannot be empty")
    .max(2000, "The message is too long"),
});

export const sendMessageSchema = z.object({
  body: z
    .string()
    .min(1, "The message cannot be empty")
    .max(2000, "The message is too long"),
});
