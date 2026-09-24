import prisma from "../../lib/prisma";

type NotificationType =
  | "BOOKING"
  | "PAYMENT"
  | "TICKET"
  | "TAXI"
  | "TRIP"
  | "LUGGAGE"
  | "PARCEL"
  | "SYSTEM";

interface CreateNotificationInput {
  userId: string;
  title: string;
  message: string;
  type: NotificationType;
}

export const createNotification = async (
  data: CreateNotificationInput
) => {
  return prisma.notification.create({
    data: {
      userId: data.userId,
      title: data.title,
      message: data.message,
      type: data.type,
      status: "UNREAD",
    },
  });
};

export const getUserNotifications = async (
  userId: string
) => {
  return prisma.notification.findMany({
    where: {
      userId,
    },

    orderBy: {
      createdAt: "desc",
    },
  });
};

export const getNotificationById = async (
  notificationId: string
) => {
  return prisma.notification.findUnique({
    where: {
      id: notificationId,
    },
  });
};

export const markNotificationAsRead = async (
  notificationId: string
) => {
  return prisma.notification.update({
    where: {
      id: notificationId,
    },

    data: {
      status: "READ",
      readAt: new Date(),
    },
  });
};

export const markAllNotificationsAsRead =
  async (userId: string) => {
    const now = new Date();

    return prisma.notification.updateMany({
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

export const getUnreadNotificationCount =
  async (userId: string) => {
    return prisma.notification.count({
      where: {
        userId,
        status: "UNREAD",
      },
    });
  };