import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";

import {
  getDeviceSummary,
  registerDeviceToken,
  releaseDeviceToken,
} from "./device.service";

import { registerDeviceTokenSchema } from "./device.schema";

export const registerToken = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData =
      registerDeviceTokenSchema.parse(req.body);

    const device = await registerDeviceToken({
      userId: req.user!.userId,

      token: validatedData.token,

      platform: validatedData.platform,
    });

    return res.status(201).json({
      success: true,
      message:
        "This device will now receive notifications.",
      data: device,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to register this device",
    });
  }
};

export const releaseToken = async (
  req: Request,
  res: Response
) => {
  try {
    // In the path rather than the body because a device token is 150-odd
    // characters of opaque text with no useful structure, and because the
    // signing-out client may already have dropped the account it was sending
    // as. The route is scoped to the signed-in account either way.
    const token = String(req.params.token ?? "").trim();

    if (!token) {
      return res.status(400).json({
        success: false,
        message:
          "A device token is required",
      });
    }

    const result = await releaseDeviceToken({
      userId: req.user!.userId,
      token,
    });

    return res.status(200).json({
      success: true,
      message:
        result.count > 0
          ? "This device will no longer receive notifications."
          : "This device was not registered.",
      data: {
        releasedCount: result.count,
      },
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to release this device",
    });
  }
};

export const listMyDevices = async (
  req: Request,
  res: Response
) => {
  try {
    const summary = await getDeviceSummary(
      req.user!.userId
    );

    return res.status(200).json({
      success: true,
      count: summary.count,
      data: summary,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to retrieve your devices",
    });
  }
};
