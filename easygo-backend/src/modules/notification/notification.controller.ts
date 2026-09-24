import {
  Request,
  Response,
} from "express";

import {
  getNotificationById,
  getUnreadNotificationCount,
  getUserNotifications,
  markAllNotificationsAsRead,
  markNotificationAsRead,
} from "./notification.service";

export const listMyNotifications =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const notifications =
        await getUserNotifications(
          req.user!.userId
        );

      return res.status(200).json({
        success: true,
        count: notifications.length,
        data: notifications,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,
        message:
          error.message ||
          "Unable to retrieve notifications",
      });
    }
  };

export const getUnreadCount = async (
  req: Request,
  res: Response
) => {
  try {
    const count =
      await getUnreadNotificationCount(
        req.user!.userId
      );

    return res.status(200).json({
      success: true,
      data: {
        unreadCount: count,
      },
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve unread notification count",
    });
  }
};

export const readNotification = async (
  req: Request,
  res: Response
) => {
  try {
    const notificationId = String(
      req.params.id
    );

    const notification =
      await getNotificationById(
        notificationId
      );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message:
          "Notification not found",
      });
    }

    if (
      notification.userId !==
      req.user!.userId
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to access this notification",
      });
    }

    if (
      notification.status === "READ"
    ) {
      return res.status(200).json({
        success: true,
        message:
          "Notification is already read",
        data: notification,
      });
    }

    const updatedNotification =
      await markNotificationAsRead(
        notificationId
      );

    return res.status(200).json({
      success: true,
      message:
        "Notification marked as read",
      data: updatedNotification,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to update notification",
    });
  }
};

export const readAllNotifications =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const result =
        await markAllNotificationsAsRead(
          req.user!.userId
        );

      return res.status(200).json({
        success: true,
        message:
          "All notifications marked as read",
        data: {
          updatedCount:
            result.count,
        },
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,
        message:
          error.message ||
          "Unable to update notifications",
      });
    }
  };