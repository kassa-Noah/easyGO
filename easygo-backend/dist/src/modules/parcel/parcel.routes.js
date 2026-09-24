"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const parcel_controller_1 = require("./parcel.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), parcel_controller_1.registerParcel);
router.get("/me", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), parcel_controller_1.listMyParcels);
router.get("/track/:trackingNumber", auth_middleware_1.authenticate, parcel_controller_1.trackParcel);
router.patch("/:id/status", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("AGENCY_STAFF", "ADMIN"), parcel_controller_1.changeParcelStatus);
router.get("/:id", auth_middleware_1.authenticate, parcel_controller_1.getParcel);
exports.default = router;
//# sourceMappingURL=parcel.routes.js.map