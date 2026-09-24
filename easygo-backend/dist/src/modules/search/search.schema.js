"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.searchTripsSchema = void 0;
const zod_1 = require("zod");
exports.searchTripsSchema = zod_1.z.object({
    originCity: zod_1.z
        .string()
        .min(2, "Origin city is required"),
    destinationCity: zod_1.z
        .string()
        .min(2, "Destination city is required"),
    travelDate: zod_1.z
        .string()
        .regex(/^\d{4}-\d{2}-\d{2}$/, "Travel date must use YYYY-MM-DD format"),
    agencyId: zod_1.z
        .string()
        .uuid("Invalid agency ID")
        .optional(),
});
//# sourceMappingURL=search.schema.js.map