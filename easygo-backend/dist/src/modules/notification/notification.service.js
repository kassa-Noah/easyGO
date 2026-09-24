"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUnreadNotificationCount = exports.markAllNotificationsAsRead = exports.markNotificationAsRead = exports.getNotificationById = exports.getUserNotifications = exports.createNotification = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const createNotification = async (data) => {
    return prisma_1.default.notification.create({
        data: {
            userId: data.userId,
            title: data.title,
            message: data.message,
            type: data.type,
            status: "UNREAD",
        },
    });
};
exports.createNotification = createNotification;
const getUserNotifications = async (userId) => {
    return prisma_1.default.notification.findMany({
        where: {
            userId,
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getUserNotifications = getUserNotifications;
const getNotificationById = async (notificationId) => {
    return prisma_1.default.notification.findUnique({
        where: {
            id: notificationId,
        },
    });
};
exports.getNotificationById = getNotificationById;
const markNotificationAsRead = async (notificationId) => {
    return prisma_1.default.notification.update({
        where: {
            id: notificationId,
        },
        data: {
            status: "READ",
            readAt: new Date(),
        },
    });
};
exports.markNotificationAsRead = markNotificationAsRead;
const markAllNotificationsAsRead = async (userId) => {
    const now = new Date();
    return prisma_1.default.notification.updateMany({
        where: {
            userId,
            status: "UNREAD",
        },
        data: {
            status: "READ",
            readAt: now,
        },
    });
};
exports.markAllNotificationsAsRead = markAllNotificationsAsRead;
const getUnreadNotificationCount = async (userId) => {
    return prisma_1.default.notification.count({
        where: {
            userId,
            status: "UNREAD",
        },
    });
};
exports.getUnreadNotificationCount = getUnreadNotificationCount;
//# sourceMappingURL=notification.service.js.map