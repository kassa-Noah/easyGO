"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.readAllNotifications = exports.readNotification = exports.getUnreadCount = exports.listMyNotifications = void 0;
const notification_service_1 = require("./notification.service");
const listMyNotifications = async (req, res) => {
    try {
        const notifications = await (0, notification_service_1.getUserNotifications)(req.user.userId);
        return res.status(200).json({
            success: true,
            count: notifications.length,
            data: notifications,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve notifications",
        });
    }
};
exports.listMyNotifications = listMyNotifications;
const getUnreadCount = async (req, res) => {
    try {
        const count = await (0, notification_service_1.getUnreadNotificationCount)(req.user.userId);
        return res.status(200).json({
            success: true,
            data: {
                unreadCount: count,
            },
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve unread notification count",
        });
    }
};
exports.getUnreadCount = getUnreadCount;
const readNotification = async (req, res) => {
    try {
        const notificationId = String(req.params.id);
        const notification = await (0, notification_service_1.getNotificationById)(notificationId);
        if (!notification) {
            return res.status(404).json({
                success: false,
                message: "Notification not found",
            });
        }
        if (notification.userId !==
            req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to access this notification",
            });
        }
        if (notification.status === "READ") {
            return res.status(200).json({
                success: true,
                message: "Notification is already read",
                data: notification,
            });
        }
        const updatedNotification = await (0, notification_service_1.markNotificationAsRead)(notificationId);
        return res.status(200).json({
            success: true,
            message: "Notification marked as read",
            data: updatedNotification,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to update notification",
        });
    }
};
exports.readNotification = readNotification;
const readAllNotifications = async (req, res) => {
    try {
        const result = await (0, notification_service_1.markAllNotificationsAsRead)(req.user.userId);
        return res.status(200).json({
            success: true,
            message: "All notifications marked as read",
            data: {
                updatedCount: result.count,
            },
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to update notifications",
        });
    }
};
exports.readAllNotifications = readAllNotifications;
//# sourceMappingURL=notification.controller.js.map