"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const journey_controller_1 = require("./journey.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
// Customer creates a door-to-door journey
// for one of their bookings.
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), journey_controller_1.addJourney);
// Customer retrieves all their own journeys.
router.get("/me", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), journey_controller_1.listMyJourneys);
// Authenticated users can retrieve a journey.
// The controller protects customer ownership.
router.get("/:id", auth_middleware_1.authenticate, journey_controller_1.getJourney);
// Journey status is controlled by operational
// actors, not by customers.
router.patch("/:id/status", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), journey_controller_1.changeJourneyStatus);
exports.default = router;
//# sourceMappingURL=journey.routes.js.map