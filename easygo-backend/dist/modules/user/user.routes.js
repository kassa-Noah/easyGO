"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const user_controller_1 = require("./user.controller");
const router = (0, express_1.Router)();
router.use(auth_middleware_1.authenticate);
router.get("/me", user_controller_1.getMe);
router.patch("/me", user_controller_1.updateMe);
router.get("/", (0, role_middleware_1.authorizeRoles)("ADMIN"), user_controller_1.listUsers);
router.get("/:id", (0, role_middleware_1.authorizeRoles)("ADMIN"), user_controller_1.getUser);
router.patch("/:id/status", (0, role_middleware_1.authorizeRoles)("ADMIN"), user_controller_1.changeUserStatus);
exports.default = router;
//# sourceMappingURL=user.routes.js.map