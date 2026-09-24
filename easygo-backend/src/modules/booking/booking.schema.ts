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