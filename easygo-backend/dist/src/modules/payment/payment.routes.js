"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const payment_controller_1 = require("./payment.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), payment_controller_1.initiatePayment);
router.get("/booking/:bookingId", auth_middleware_1.authenticate, payment_controller_1.listBookingPayments);
router.patch("/:id/simulate", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), payment_controller_1.simulatePayment);
router.get("/:id", auth_middleware_1.authenticate, payment_controller_1.getPayment);
exports.default = router;
//# sourceMappingURL=payment.routes.js.map