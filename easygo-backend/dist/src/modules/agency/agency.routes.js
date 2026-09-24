"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const agency_controller_1 = require("./agency.controller");
const router = (0, express_1.Router)();
// Public routes
router.get("/", agency_controller_1.listAgencies);
router.get("/:id", agency_controller_1.getAgency);
router.get("/:id/branches", agency_controller_1.listBranches);
// Admin only
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN"), agency_controller_1.addAgency);
// ADMIN or AGENCY_STAFF
router.patch("/:id", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), agency_controller_1.editAgency);
router.post("/:id/branches", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), agency_controller_1.addBranch);
router.patch("/:id/branches/:branchId", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN", "AGENCY_STAFF"), agency_controller_1.editBranch);
exports.default = router;
//# sourceMappingURL=agency.routes.js.map