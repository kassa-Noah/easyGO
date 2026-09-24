"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const admin_controller_1 = require("./admin.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
router.use(auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN"));
router.get("/dashboard", admin_controller_1.dashboard);
router.get("/statistics", admin_controller_1.dashboardStatistics);
router.get("/bookings", admin_controller_1.listAllBookings);
router.get("/payments", admin_controller_1.listAllPayments);
router.get("/parcels", admin_controller_1.listAllParcels);
router.get("/luggage", admin_controller_1.listAllLuggage);
exports.default = router;
//# sourceMappingURL=admin.routes.js.map