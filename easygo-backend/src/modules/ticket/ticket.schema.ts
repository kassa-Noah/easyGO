import { z } from "zod";

export const createTicketSchema = z.object({
  bookingId: z
    .string()
    .uuid("Invalid booking ID"),
});