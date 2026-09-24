"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateTaxiAssignmentSchema = exports.assignTaxiSchema = void 0;
const zod_1 = require("zod");
exports.assignTaxiSchema = zod_1.z.object({
    providerId: zod_1.z
        .string()
        .uuid("Invalid taxi provider ID"),
    segmentType: zod_1.z.enum([
        "HOME_TO_DEPARTURE_AGENCY",
        "ARRIVAL_AGENCY_TO_DESTINATION",
    ]),
    estimatedFare: zod_1.z
        .number()
        .nonnegative("Estimated fare cannot be negative")
        .optional(),
});
exports.updateTaxiAssignmentSchema = zod_1.z
    .object({
    status: zod_1.z
        .enum([
        "PENDING",
        "DRIVER_ASSIGNED",
        "DRIVER_ARRIVING",
        "PASSENGER_PICKED_UP",
        "COMPLETED",
        "CANCELLED",
    ])
        .optional(),
    driverName: zod_1.z
        .string()
        .trim()
        .min(2, "Driver name must contain at least 2 characters")
        .optional(),
    driverPhone: zod_1.z
        .string()
        .trim()
        .min(6, "Invalid driver phone number")
        .optional(),
    vehicleRegistration: zod_1.z
        .string()
        .trim()
        .min(2, "Invalid vehicle registration")
        .optional(),
    vehicleDescription: zod_1.z
        .string()
        .trim()
        .min(2, "Invalid vehicle description")
        .optional(),
    externalReference: zod_1.z
        .string()
        .trim()
        .min(1, "Invalid external reference")
        .optional(),
    finalFare: zod_1.z
        .number()
        .nonnegative("Final fare cannot be negative")
        .optional(),
})
    .refine((data) => Object.values(data).some((value) => value !== undefined), {
    message: "At least one field must be provided",
});
//# sourceMappingURL=taxi.schema.js.map