import { readFileSync } from "node:fs";

import {
  cert,
  getApps,
  initializeApp,
  type App,
} from "firebase-admin/app";

import {
  getMessaging,
  type Messaging,
} from "firebase-admin/messaging";

import prisma from "./prisma";

/**
 * Firebase Cloud Messaging.
 *
 * A notification written to the database reaches the app the next time the
 * reader opens it. A push reaches the phone whether or not the app is open,
 * which is the point of the phone buzzing when a booking is confirmed.
 *
 * The credential is a service account key, pointed at by
 * `GOOGLE_APPLICATION_CREDENTIALS`. It is deliberately optional. Without it the
 * platform behaves exactly as it did before this file existed: notifications are
 * still written and still read, they simply do not reach a phone. A missing
 * credential is a deployment that has not set push up, not a failure, and it
 * must never be able to break a booking.
 */

/// The reason the client last reported, for the log. `undefined` before the
/// first attempt, `null` once a client exists.
let client: Messaging | null | undefined;

/// Whether push is configured at all, without attempting to build a client.
///
/// The route that reports status uses this rather than `client`, because asking
/// for a client is what logs the "not configured" line and that should happen
/// once, when a push is actually attempted.
export const isPushConfigured = (): boolean =>
  Boolean(process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim());

/**
 * The messaging client, or null when push is not configured or could not be
 * set up.
 *
 * Built once and remembered. Every failure is returned as null rather than
 * thrown: this is called from the path that records a notification, and a
 * problem with push must not be able to fail that.
 */
function messagingClient(): Messaging | null {
  if (client !== undefined) {
    return client;
  }

  client = null;

  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim();

  if (!keyPath) {
    console.log(
      "Push is not configured, so notifications stay in the app. Set " +
        "GOOGLE_APPLICATION_CREDENTIALS to a Firebase service account key to " +
        "send them to a phone as well."
    );

    return client;
  }

  try {
    // Read and parse rather than relying on application default credentials:
    // this way a missing or malformed file says which file and which problem,
    // instead of surfacing as an authentication error much later.
    const key = JSON.parse(readFileSync(keyPath, "utf8"));

    if (key.type !== "service_account") {
      throw new Error(
        `it is not a service account key (its "type" is ` +
          `${JSON.stringify(key.type)}, and it has to be "service_account"). ` +
          `google-services.json is the app's config and cannot send anything.`
      );
    }

    // `initializeApp` throws if the app already exists, and this module can be
    // imported more than once by a reloading dev server.
    const app: App = getApps()[0] ?? initializeApp({ credential: cert(key) });

    client = getMessaging(app);

    console.log(
      `Push configured for Firebase project ${key.project_id}.`
    );
  } catch (error: any) {
    console.error(
      `Push is switched off because the service account key could not be ` +
        `used: ${error?.message ?? error}`
    );
  }

  return client;
}

/// The FCM error codes that mean the token is dead rather than the send having
/// failed. A token is retired when the app is uninstalled, the data is cleared,
/// or the app is restored onto a different device, and Firebase never reuses it.
const DEAD_TOKEN_CODES = new Set<string>([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
  "messaging/invalid-argument",
]);

export interface PushContent {
  title: string;
  body: string;

  /// Carried through to the app so a push can open the record it is about, the
  /// same way the in-app notification does. Values must be strings; FCM will
  /// not carry anything else.
  data?: Record<string, string>;
}

/**
 * Sends to every device the account is signed in on.
 *
 * Never throws. It is called from the path that records a notification, and a
 * push is a courtesy that must not be able to undo the thing it is announcing.
 */
export async function sendPushToUser(
  userId: string,
  content: PushContent
): Promise<void> {
  const client = messagingClient();

  if (!client) {
    return;
  }

  try {
    const devices = await prisma.deviceToken.findMany({
      where: { userId },
      select: { token: true },
    });

    if (devices.length === 0) {
      return;
    }

    const tokens = devices.map((device) => device.token);

    const response = await client.sendEachForMulticast({
      tokens,
      notification: {
        title: content.title,
        body: content.body,
      },
      data: content.data,
      // Without this the message is not delivered while the phone is asleep,
      // which is most of the time.
      android: {
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });

    // Tokens Firebase reports as unknown are removed, so a phone that has been
    // uninstalled stops being retried for the life of the account. This is the
    // only cleanup FCM offers, and skipping it means every later push pays for
    // every dead device the account ever used.
    const dead: string[] = [];

    response.responses.forEach((result, index) => {
      if (result.error && DEAD_TOKEN_CODES.has(result.error.code)) {
        dead.push(tokens[index]);
      }
    });

    if (dead.length > 0) {
      await prisma.deviceToken.deleteMany({
        where: { token: { in: dead } },
      });

      console.log(
        `Removed ${dead.length} device token(s) Firebase no longer recognises.`
      );
    }
  } catch (error: any) {
    console.error(
      `Unable to push to ${userId}: ${error?.message ?? error}`
    );
  }
}
