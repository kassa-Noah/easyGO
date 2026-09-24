"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateJourneyStatusSchema = exports.createJourneySchema = void 0;
const zod_1 = require("zod");
exports.createJourneySchema = zod_1.z.object({
    bookingId: zod_1.z
        .string()
        .uuid("Invalid booking ID"),
    pickupAddress: zod_1.z
        .string()
        .trim()
        .min(5, "Pickup address must contain at least 5 characters")
        .max(255, "Pickup address cannot exceed 255 characters"),
    pickupLatitude: zod_1.z
        .number()
        .min(-90, "Invalid pickup latitude")
        .max(90, "Invalid pickup latitude")
        .optional(),
    pickupLongitude: zod_1.z
        .number()
        .min(-180, "Invalid pickup longitude")
        .max(180, "Invalid pickup longitude")
        .optional(),
    destinationAddress: zod_1.z
        .string()
        .trim()
        .min(5, "Destination address must contain at least 5 characters")
        .max(255, "Destination address cannot exceed 255 characters"),
    destinationLatitude: zod_1.z
        .number()
        .min(-90, "Invalid destination latitude")
        .max(90, "Invalid destination latitude")
        .optional(),
    destinationLongitude: zod_1.z
        .number()
        .min(-180, "Invalid destination longitude")
        .max(180, "Invalid destination longitude")
        .optional(),
});
exports.updateJourneyStatusSchema = zod_1.z.object({
    status: zod_1.z.enum([
        "PENDING",
        "CONFIRMED",
        "PICKUP_ASSIGNED",
        "PICKUP_IN_PROGRESS",
        "AT_DEPARTURE_AGENCY",
        "INTERURBAN_IN_PROGRESS",
        "AT_ARRIVAL_AGENCY",
        "DROPOFF_ASSIGNED",
        "DROPOFF_IN_PROGRESS",
        "COMPLETED",
        "CANCELLED",
    ]),
});
//# sourceMappingURL=journey.schema.js.map