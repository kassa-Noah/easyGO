"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const ticket_controller_1 = require("./ticket.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
// Customer generates a ticket for
// their successfully paid booking.
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), ticket_controller_1.generateTicket);
// Customer retrieves all their tickets.
router.get("/me", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), ticket_controller_1.listMyTickets);
// Retrieve ticket using booking ID.
router.get("/booking/:bookingId", auth_middleware_1.authenticate, ticket_controller_1.getBookingTicket);
// Agency staff or administrator
// verifies a ticket number.
router.get("/verify/:ticketNumber", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("AGENCY_STAFF", "ADMIN"), ticket_controller_1.verifyTicket);
// Retrieve one ticket by ID.
router.get("/:id", auth_middleware_1.authenticate, ticket_controller_1.getTicket);
exports.default = router;
//# sourceMappingURL=ticket.routes.js.map