"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.simulatePaymentSchema = exports.initiatePaymentSchema = void 0;
const zod_1 = require("zod");
exports.initiatePaymentSchema = zod_1.z.object({
    bookingId: zod_1.z
        .string()
        .uuid("Invalid booking ID"),
    method: zod_1.z.enum([
        "MOBILE_MONEY",
        "CASH",
        "CARD",
        "SIMULATED",
    ]),
});
exports.simulatePaymentSchema = zod_1.z.object({
    result: zod_1.z.enum([
        "SUCCESSFUL",
        "FAILED",
    ]),
});
//# sourceMappingURL=payment.schema.js.map