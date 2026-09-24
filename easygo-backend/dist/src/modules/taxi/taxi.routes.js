"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const taxi_controller_1 = require("./taxi.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
// Operational actor assigns a taxi
// to one segment of a journey.
router.post("/journeys/:journeyId/assignments", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), taxi_controller_1.assignTaxi);
// Customer, agency staff or admin can
// retrieve the assignments of a journey.
// Ownership/agency authorization is checked
// by the controller.
router.get("/journeys/:journeyId/assignments", auth_middleware_1.authenticate, taxi_controller_1.listJourneyTaxiAssignments);
// Retrieve one taxi assignment.
router.get("/assignments/:id", auth_middleware_1.authenticate, taxi_controller_1.getTaxiAssignment);
// Operational actors update driver,
// vehicle, fare and assignment status.
router.patch("/assignments/:id", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), taxi_controller_1.changeTaxiAssignment);
exports.default = router;
//# sourceMappingURL=taxi.routes.js.map