"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateRouteSchema = exports.createRouteSchema = void 0;
const zod_1 = require("zod");
exports.createRouteSchema = zod_1.z.object({
    originBranchId: zod_1.z.string().uuid("Invalid origin branch ID"),
    destinationBranchId: zod_1.z.string().uuid("Invalid destination branch ID"),
    distanceKm: zod_1.z.number().positive("Distance must be greater than 0").optional(),
    estimatedDurationMinutes: zod_1.z
        .number()
        .int()
        .positive("Estimated duration must be greater than 0")
        .optional(),
    baseFare: zod_1.z.number().positive("Base fare must be greater than 0"),
});
exports.updateRouteSchema = zod_1.z.object({
    originBranchId: zod_1.z.string().uuid().optional(),
    destinationBranchId: zod_1.z.string().uuid().optional(),
    distanceKm: zod_1.z.number().positive().optional(),
    estimatedDurationMinutes: zod_1.z.number().int().positive().optional(),
    baseFare: zod_1.z.number().positive().optional(),
    isActive: zod_1.z.boolean().optional(),
});
//# sourceMappingURL=route.schema.js.map