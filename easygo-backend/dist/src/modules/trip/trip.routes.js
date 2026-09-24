"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const trip_controller_1 = require("./trip.controller");
const router = (0, express_1.Router)();
// Public
router.get("/", trip_controller_1.listTrips);
router.get("/:id", trip_controller_1.getTrip);
// ADMIN or agency staff
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), trip_controller_1.addTrip);
router.patch("/:id", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), trip_controller_1.editTrip);
exports.default = router;
//# sourceMappingURL=trip.routes.js.map