"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateParcelStatusSchema = exports.createParcelSchema = void 0;
const zod_1 = require("zod");
exports.createParcelSchema = zod_1.z.object({
    description: zod_1.z
        .string()
        .trim()
        .min(2, "Parcel description is required")
        .max(500, "Parcel description cannot exceed 500 characters"),
    weightKg: zod_1.z
        .number()
        .positive("Weight must be greater than zero")
        .max(100, "Weight cannot exceed 100 kg")
        .optional(),
    recipientName: zod_1.z
        .string()
        .trim()
        .min(2, "Recipient name is required")
        .max(100, "Recipient name cannot exceed 100 characters"),
    recipientPhone: zod_1.z
        .string()
        .trim()
        .min(6, "Recipient phone is required")
        .max(30, "Recipient phone cannot exceed 30 characters"),
    originBranchId: zod_1.z
        .string()
        .uuid("Invalid origin branch ID"),
    destinationBranchId: zod_1.z
        .string()
        .uuid("Invalid destination branch ID"),
    recipientUserId: zod_1.z
        .string()
        .uuid("Invalid recipient user ID")
        .optional(),
    tripId: zod_1.z
        .string()
        .uuid("Invalid trip ID")
        .optional(),
});
exports.updateParcelStatusSchema = zod_1.z.object({
    status: zod_1.z.enum([
        "RECEIVED_AT_ORIGIN_AGENCY",
        "LOADED",
        "IN_TRANSIT",
        "ARRIVED_AT_DESTINATION_AGENCY",
        "READY_FOR_COLLECTION",
        "COLLECTED",
        "DELIVERED",
        "LOST",
        "CANCELLED",
    ]),
    location: zod_1.z
        .string()
        .trim()
        .max(200, "Location cannot exceed 200 characters")
        .optional(),
    description: zod_1.z
        .string()
        .trim()
        .max(500, "Description cannot exceed 500 characters")
        .optional(),
});
//# sourceMappingURL=parcel.schema.js.map