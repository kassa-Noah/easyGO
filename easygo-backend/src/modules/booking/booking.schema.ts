import { z } from "zod";

export const createBookingSchema = z.object({
  tripId: z
    .string()
    .uuid("Invalid trip ID"),

  numberOfSeats: z
    .number()
    .int("Number of seats must be an integer")
    .min(1, "At least one seat must be booked")
    .max(10, "A maximum of 10 seats can be booked"),
});

// Agency staff may only move a booking to a terminal state.
//
// CONFIRMED is deliberately excluded: a booking is confirmed by a
// successful payment and never by hand, which keeps the rule that a
// booking only reaches CONFIRMED after its payment succeeded.
export const updateBookingStatusSchema = z.object({
  status: z.enum([
    "CANCELLED",
    "COMPLETED",
  ]),
});