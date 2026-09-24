import { z } from "zod";

export const initiatePaymentSchema = z.object({
  bookingId: z
    .string()
    .uuid("Invalid booking ID"),

  method: z.enum([
    "MOBILE_MONEY",
    "CASH",
    "CARD",
    "SIMULATED",
  ]),
});

export const simulatePaymentSchema = z.object({
  result: z.enum([
    "SUCCESSFUL",
    "FAILED",
  ]),
});