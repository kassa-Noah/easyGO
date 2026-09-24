"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const luggage_controller_1 = require("./luggage.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), luggage_controller_1.registerLuggage);
router.get("/me", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), luggage_controller_1.listMyLuggage);
router.get("/track/:trackingNumber", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), luggage_controller_1.trackLuggage);
router.patch("/:id/status", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("AGENCY_STAFF", "ADMIN"), luggage_controller_1.changeLuggageStatus);
router.get("/:id", auth_middleware_1.authenticate, luggage_controller_1.getLuggage);
exports.default = router;
//# sourceMappingURL=luggage.routes.js.map