import { z } from "zod";

export const registerDeviceTokenSchema = z.object({
  // The message is given for the missing case as well as the blank one, so a
  // client that omits the field reads the same sentence as one that sends
  // whitespace. Without it Zod answers a missing field with its own wording —
  // "expected string, received undefined" — which is written for the developer
  // who forgot the field, not for anyone reading an error message.
  token: z
    .string({ error: "A device token is required" })
    .trim()
    .min(1, "A device token is required"),

  platform: z.enum([
    "ANDROID",
    "IOS",
    "WEB",
  ]),
});
