"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const notification_controller_1 = require("./notification.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const router = (0, express_1.Router)();
router.get("/me", auth_middleware_1.authenticate, notification_controller_1.listMyNotifications);
router.get("/unread-count", auth_middleware_1.authenticate, notification_controller_1.getUnreadCount);
router.patch("/read-all", auth_middleware_1.authenticate, notification_controller_1.readAllNotifications);
router.patch("/:id/read", auth_middleware_1.authenticate, notification_controller_1.readNotification);
exports.default = router;
//# sourceMappingURL=notification.routes.js.map