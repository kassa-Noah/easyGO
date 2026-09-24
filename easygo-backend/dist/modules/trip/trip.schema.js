"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateTripSchema = exports.createTripSchema = void 0;
const zod_1 = require("zod");
exports.createTripSchema = zod_1.z.object({
    departureTime: zod_1.z.string().datetime(),
    arrivalTime: zod_1.z.string().datetime().optional(),
    price: zod_1.z.number().positive("Price must be greater than 0"),
    totalSeats: zod_1.z
        .number()
        .int()
        .positive("Total seats must be greater than 0"),
    agencyId: zod_1.z.string().uuid("Invalid agency ID"),
    routeId: zod_1.z.string().uuid("Invalid route ID"),
    vehicleId: zod_1.z.string().uuid("Invalid vehicle ID").optional(),
});
exports.updateTripSchema = zod_1.z.object({
    departureTime: zod_1.z.string().datetime().optional(),
    arrivalTime: zod_1.z.string().datetime().optional(),
    price: zod_1.z.number().positive().optional(),
    totalSeats: zod_1.z.number().int().positive().optional(),
    vehicleId: zod_1.z.string().uuid().nullable().optional(),
    status: zod_1.z
        .enum([
        "SCHEDULED",
        "BOARDING",
        "DEPARTED",
        "ARRIVED",
        "CANCELLED",
    ])
        .optional(),
});
//# sourceMappingURL=trip.schema.js.map