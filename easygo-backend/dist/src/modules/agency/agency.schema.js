"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateBranchSchema = exports.createBranchSchema = exports.updateAgencySchema = exports.createAgencySchema = void 0;
const zod_1 = require("zod");
exports.createAgencySchema = zod_1.z.object({
    name: zod_1.z.string().min(2, "Agency name is required"),
    description: zod_1.z.string().optional(),
    email: zod_1.z.string().email("Invalid email").optional(),
    phone: zod_1.z.string().min(8, "Invalid phone number").optional(),
    logoUrl: zod_1.z.string().url("Invalid logo URL").optional(),
});
exports.updateAgencySchema = zod_1.z.object({
    name: zod_1.z.string().min(2).optional(),
    description: zod_1.z.string().optional(),
    email: zod_1.z.string().email().optional(),
    phone: zod_1.z.string().min(8).optional(),
    logoUrl: zod_1.z.string().url().optional(),
    isActive: zod_1.z.boolean().optional(),
});
exports.createBranchSchema = zod_1.z.object({
    name: zod_1.z.string().min(2, "Branch name is required"),
    city: zod_1.z.string().min(2, "City is required"),
    address: zod_1.z.string().min(2, "Address is required"),
    latitude: zod_1.z.number(),
    longitude: zod_1.z.number(),
    phone: zod_1.z.string().min(8).optional(),
});
exports.updateBranchSchema = zod_1.z.object({
    name: zod_1.z.string().min(2).optional(),
    city: zod_1.z.string().min(2).optional(),
    address: zod_1.z.string().min(2).optional(),
    latitude: zod_1.z.number().optional(),
    longitude: zod_1.z.number().optional(),
    phone: zod_1.z.string().min(8).optional(),
});
//# sourceMappingURL=agency.schema.js.map