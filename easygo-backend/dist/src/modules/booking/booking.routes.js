"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const booking_controller_1 = require("./booking.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
// Customer creates a reservation.
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), booking_controller_1.addBooking);
// Customer retrieves their bookings.
router.get("/me", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), booking_controller_1.listMyBookings);
// Authenticated customer, relevant agency
// staff, or administrator retrieves one booking.
router.get("/:id", auth_middleware_1.authenticate, booking_controller_1.getBooking);
// Customer cancels their own booking.
router.patch("/:id/cancel", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), booking_controller_1.cancelMyBooking);
exports.default = router;
//# sourceMappingURL=booking.routes.js.map