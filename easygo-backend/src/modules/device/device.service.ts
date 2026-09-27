import prisma from "../../lib/prisma";
import { isPushConfigured } from "../../lib/push";

type DevicePlatform =
  | "ANDROID"
  | "IOS"
  | "WEB";

/**
 * Records that this account is signed in on a device that can be pushed to.
 *
 * An upsert keyed on the token, not on the account. Firebase issues one token
 * per installation, so a phone signed into a second account reuses the same
 * token, and the row has to move rather than be duplicated. Leaving it on the
 * previous account would send that account's notifications to whoever is
 * holding the phone now.
 */
export const registerDeviceToken = async (data: {
  userId: string;
  token: string;
  platform: DevicePlatform;
}) => {
  return prisma.deviceToken.upsert({
    where: {
      token: data.token,
    },

    create: {
      token: data.token,
      platform: data.platform,
      userId: data.userId,
    },

    update: {
      userId: data.userId,
      platform: data.platform,
      lastSeenAt: new Date(),
    },
  });
};

/**
 * Stops pushing to a device.
 *
 * Scoped to the signed-in account as well as the token, so one account cannot
 * release another's device. Deleting nothing is a success, not a 404: signing
 * out on a device that was never registered is an ordinary thing to do.
 */
export const releaseDeviceToken = async (data: {
  userId: string;
  token: string;
}) => {
  return prisma.deviceToken.deleteMany({
    where: {
      token: data.token,
      userId: data.userId,
    },
  });
};

/**
 * The account's devices, and whether the platform can push to them at all.
 *
 * `pushConfigured` is the honest half of this. Registering a token succeeds
 * whether or not the server holds a credential, so a device count on its own
 * would suggest pushes are being delivered when nothing was ever sent.
 */
export const getDeviceSummary = async (
  userId: string
) => {
  const devices = await prisma.deviceToken.findMany({
    where: {
      userId,
    },

    select: {
      id: true,
      platform: true,
      createdAt: true,
      lastSeenAt: true,
    },

    orderBy: {
      lastSeenAt: "desc",
    },
  });

  return {
    pushConfigured: isPushConfigured(),
    count: devices.length,
    devices,
  };
};
