"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createBookingSchema = void 0;
const zod_1 = require("zod");
exports.createBookingSchema = zod_1.z.object({
    tripId: zod_1.z
        .string()
        .uuid("Invalid trip ID"),
    numberOfSeats: zod_1.z
        .number()
        .int("Number of seats must be an integer")
        .min(1, "At least one seat must be booked")
        .max(10, "A maximum of 10 seats can be booked"),
});
//# sourceMappingURL=booking.schema.js.map