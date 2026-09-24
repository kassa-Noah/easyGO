"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const route_controller_1 = require("./route.controller");
const router = (0, express_1.Router)();
// Public
router.get("/", route_controller_1.listRoutes);
router.get("/:id", route_controller_1.getRoute);
// Admin only
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN"), route_controller_1.addRoute);
router.patch("/:id", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN"), route_controller_1.editRoute);
exports.default = router;
//# sourceMappingURL=route.routes.js.map