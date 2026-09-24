"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.loginSchema = exports.registerSchema = void 0;
const zod_1 = require("zod");
exports.registerSchema = zod_1.z.object({
    firstName: zod_1.z.string().min(2, "First name is required"),
    lastName: zod_1.z.string().min(2, "Last name is required"),
    email: zod_1.z.string().email("Invalid email address"),
    phone: zod_1.z.string().min(8, "Invalid phone number"),
    password: zod_1.z.string().min(6, "Password must contain at least 6 characters"),
});
exports.loginSchema = zod_1.z.object({
    email: zod_1.z.string().email("Invalid email address"),
    password: zod_1.z.string().min(1, "Password is required"),
});
//# sourceMappingURL=auth.schema.js.map