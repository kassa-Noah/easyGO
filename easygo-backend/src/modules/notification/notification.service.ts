import prisma from "../../lib/prisma";
import { sendPushToUser } from "../../lib/push";

type NotificationType =
  | "BOOKING"
  | "PAYMENT"
  | "TICKET"
  | "TAXI"
  | "TRIP"
  | "LUGGAGE"
  | "PARCEL"
  | "MESSAGE"
  | "SYSTEM";

/**
 * The kind of record a notification describes.
 *
 * Must stay in step with the `NotificationReference` enum in the Prisma schema.
 */
export type NotificationReference =
  | "CONVERSATION"
  | "BOOKING"
  | "TRIP"
  | "PARCEL"
  | "LUGGAGE"
  | "AGENCY";

interface CreateNotificationInput {
  userId: string;
  title: string;
  message: string;
  type: NotificationType;

  /**
   * The record the message is about.
   *
   * Both halves are supplied together or not at all. A notification with no
   * reference is one that cannot lead anywhere, which is a normal state for a
   * platform-wide notice.
   */
  referenceType?: NotificationReference;
  referenceId?: string;
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

      referenceType: data.referenceType,
      referenceId: data.referenceId,
    },
  });
};

/**
 * Records a notification without letting a failure break the operation that
 * triggered it.
 *
 * Notifications are a side effect of paying, of a status changing, and so on. A
 * problem writing one must never roll back or fail the action the user asked
 * for, so the error is logged and swallowed.
 *
 * It is also the single place a push is sent from. Every notification in the
 * platform is written through here, so pushing from here means a new one cannot
 * be added later that reaches the in-app list and silently forgets the phone.
 */
export const notifySafely = async (
  data: CreateNotificationInput
) => {
  let notification: Awaited<ReturnType<typeof createNotification>>;

  try {
    notification = await createNotification(data);
  } catch (error) {
    console.error(
      `Unable to create a ${data.type} notification for ${data.userId}:`,
      error
    );

    return null;
  }

  // Only after the row is stored. A push that opened a notification the list
  // does not contain would be worse than no push at all.
  //
  // `sendPushToUser` returns rather than throws, so this cannot fail the caller
  // either. It is the same promise the write above makes: the thing being
  // announced happened, and nothing about announcing it may undo that.
  await sendPushToUser(data.userId, {
    title: data.title,
    body: data.message,
    data: pushDataFor(notification),
  });

  return notification;
};

/**
 * The payload a push carries so that opening it lands where opening the
 * notification does.
 *
 * Every value has to be a string, because that is all FCM will carry. The
 * reference is left out rather than sent empty when there is none, so the app
 * can tell "no reference" from "a reference that happened to be blank".
 */
const pushDataFor = (
  notification: Awaited<ReturnType<typeof createNotification>>
): Record<string, string> => {
  const data: Record<string, string> = {
    notificationId: notification.id,
    type: notification.type,
  };

  if (notification.referenceType) {
    data.referenceType = notification.referenceType;
  }

  if (notification.referenceId) {
    data.referenceId = notification.referenceId;
  }

  return data;
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