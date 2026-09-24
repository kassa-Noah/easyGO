"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateLuggageStatusSchema = exports.createLuggageSchema = void 0;
const zod_1 = require("zod");
exports.createLuggageSchema = zod_1.z.object({
    bookingId: zod_1.z
        .string()
        .uuid("Invalid booking ID"),
    description: zod_1.z
        .string()
        .trim()
        .max(500)
        .optional(),
    weightKg: zod_1.z
        .number()
        .positive("Weight must be greater than zero")
        .max(100, "Weight cannot exceed 100 kg")
        .optional(),
});
exports.updateLuggageStatusSchema = zod_1.z.object({
    status: zod_1.z.enum([
        "RECEIVED_AT_AGENCY",
        "LOADED",
        "IN_TRANSIT",
        "ARRIVED_AT_DESTINATION_AGENCY",
        "READY_FOR_COLLECTION",
        "DELIVERED",
        "LOST",
    ]),
    location: zod_1.z
        .string()
        .trim()
        .max(200)
        .optional(),
    description: zod_1.z
        .string()
        .trim()
        .max(500)
        .optional(),
});
//# sourceMappingURL=luggage.schema.js.map