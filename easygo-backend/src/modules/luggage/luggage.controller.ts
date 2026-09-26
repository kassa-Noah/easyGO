import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";

import {
  createLuggage,
  getAgencyStaffMembership,
  getBookingForLuggage,
  getLuggageById,
  getLuggageByTrackingNumber,
  getUserLuggage,
  updateLuggageStatus,
} from "./luggage.service";

import {
  createLuggageSchema,
  updateLuggageStatusSchema,
} from "./luggage.schema";

import {
  notifySafely,
} from "../notification/notification.service";

export const registerLuggage = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData =
      createLuggageSchema.parse(
        req.body
      );

    const booking =
      await getBookingForLuggage(
        validatedData.bookingId
      );

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    if (
      booking.userId !==
      req.user!.userId
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to register luggage for this booking",
      });
    }

    if (
      booking.status !==
      "CONFIRMED"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Luggage can only be registered for a confirmed booking",
      });
    }

    const luggage =
      await createLuggage(
        validatedData
      );

    return res.status(201).json({
      success: true,
      message:
        "Luggage registered successfully",
      data: luggage,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to register luggage",
    });
  }
};

export const listMyLuggage = async (
  req: Request,
  res: Response
) => {
  try {
    const luggage =
      await getUserLuggage(
        req.user!.userId
      );

    return res.status(200).json({
      success: true,
      count: luggage.length,
      data: luggage,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to retrieve luggage",
    });
  }
};

export const getLuggage = async (
  req: Request,
  res: Response
) => {
  try {
    const luggage =
      await getLuggageById(
        String(req.params.id)
      );

    if (!luggage) {
      return res.status(404).json({
        success: false,
        message:
          "Luggage not found",
      });
    }

    if (
      req.user!.role ===
        "CUSTOMER" &&
      luggage.booking.userId !==
        req.user!.userId
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to view this luggage",
      });
    }

    if (
      req.user!.role ===
      "AGENCY_STAFF"
    ) {
      const membership =
        await getAgencyStaffMembership(
          req.user!.userId,
          luggage.booking.trip
            .agencyId
        );

      if (!membership) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to view this luggage",
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: luggage,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to retrieve luggage",
    });
  }
};

export const trackLuggage = async (
  req: Request,
  res: Response
) => {
  try {
    const luggage =
      await getLuggageByTrackingNumber(
        String(
          req.params.trackingNumber
        )
      );

    if (!luggage) {
      return res.status(404).json({
        success: false,
        message:
          "Luggage tracking number not found",
      });
    }

    if (
      luggage.booking.userId !==
      req.user!.userId
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to track this luggage",
      });
    }

    return res.status(200).json({
      success: true,
      data: luggage,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to track luggage",
    });
  }
};

export const changeLuggageStatus =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const luggageId = String(
        req.params.id
      );

      const luggage =
        await getLuggageById(
          luggageId
        );

      if (!luggage) {
        return res.status(404).json({
          success: false,
          message:
            "Luggage not found",
        });
      }

      if (
        req.user!.role ===
        "AGENCY_STAFF"
      ) {
        const membership =
          await getAgencyStaffMembership(
            req.user!.userId,
            luggage.booking.trip
              .agencyId
          );

        if (!membership) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to update this luggage",
          });
        }
      }

      const validatedData =
        updateLuggageStatusSchema.parse(
          req.body
        );

      const updatedLuggage =
        await updateLuggageStatus({
          luggageId,

          status:
            validatedData.status,

          location:
            validatedData.location,

          description:
            validatedData.description,

          updatedById:
            req.user!.userId,
        });

      // The traveler should hear about the change without having to poll the
      // tracker.
      await notifySafely({
        userId: luggage.booking.userId,

        title: "Luggage updated",

        message:
          `Luggage ${luggage.trackingNumber} is now ` +
          `${validatedData.status.toLowerCase().split("_").join(" ")}.`,

        type: "LUGGAGE",
      });

      return res.status(200).json({
        success: true,
        message:
          "Luggage status updated successfully",
        data: updatedLuggage,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message:
          messageOf(error) ||
          "Unable to update luggage status",
      });
    }
  };