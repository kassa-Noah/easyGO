"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTicketSchema = void 0;
const zod_1 = require("zod");
exports.createTicketSchema = zod_1.z.object({
    bookingId: zod_1.z
        .string()
        .uuid("Invalid booking ID"),
});
//# sourceMappingURL=ticket.schema.js.map