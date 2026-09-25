import { Request, Response } from "express";

import {
  createJourney,
  getBookingForJourney,
  getJourneyById,
  getUserJourneys,
  updateJourneyStatus,
} from "./journey.service";

import {
  createJourneySchema,
  updateJourneyStatusSchema,
} from "./journey.schema";

import {
  requestLastMileTaxiAssignment,
} from "../taxi/taxi.service";

export const addJourney = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData = createJourneySchema.parse(req.body);

    const booking = await getBookingForJourney(
      validatedData.bookingId
    );

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    if (booking.userId !== req.user!.userId) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to create a journey for this booking",
      });
    }

    if (booking.journey) {
      return res.status(409).json({
        success: false,
        message:
          "A door-to-door journey already exists for this booking",
      });
    }

    if (booking.status === "CANCELLED") {
      return res.status(400).json({
        success: false,
        message:
          "A journey cannot be created for a cancelled booking",
      });
    }

    if (booking.trip.status === "CANCELLED") {
      return res.status(400).json({
        success: false,
        message:
          "A journey cannot be created for a cancelled trip",
      });
    }

    const journey = await createJourney(
      req.user!.userId,
      validatedData
    );

    return res.status(201).json({
      success: true,
      message:
        "Door-to-door journey created successfully",
      data: journey,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to create door-to-door journey",
    });
  }
};

export const listMyJourneys = async (
  req: Request,
  res: Response
) => {
  try {
    const journeys = await getUserJourneys(
      req.user!.userId
    );

    return res.status(200).json({
      success: true,
      count: journeys.length,
      data: journeys,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve journeys",
    });
  }
};

export const getJourney = async (
  req: Request,
  res: Response
) => {
  try {
    const journeyId = String(req.params.id);

    const journey = await getJourneyById(journeyId);

    if (!journey) {
      return res.status(404).json({
        success: false,
        message: "Journey not found",
      });
    }

    if (
      req.user!.role === "CUSTOMER" &&
      journey.userId !== req.user!.userId
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to view this journey",
      });
    }

    return res.status(200).json({
      success: true,
      data: journey,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve journey",
    });
  }
};

export const changeJourneyStatus = async (
  req: Request,
  res: Response
) => {
  try {
    const journeyId = String(req.params.id);

    const existingJourney = await getJourneyById(
      journeyId
    );

    if (!existingJourney) {
      return res.status(404).json({
        success: false,
        message: "Journey not found",
      });
    }

    const validatedData =
      updateJourneyStatusSchema.parse(req.body);

    let journey = await updateJourneyStatus(
      journeyId,
      validatedData.status
    );

    // Marking the journey as DROPOFF_ASSIGNED means the traveller
    // has reached the arrival agency, so the last-mile ride is
    // requested at that point. A mock provider failure must never
    // fail the status change itself, and the refreshed journey is
    // returned so the response already carries the new driver.
    if (
      validatedData.status ===
      "DROPOFF_ASSIGNED"
    ) {
      try {
        await requestLastMileTaxiAssignment(
          journeyId
        );

        const refreshedJourney =
          await getJourneyById(journeyId);

        if (refreshedJourney) {
          journey = refreshedJourney;
        }
      } catch (error) {
        console.error(
          "Unable to request the last-mile taxi assignment:",
          error
        );
      }
    }

    return res.status(200).json({
      success: true,
      message:
        "Journey status updated successfully",
      data: journey,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to update journey status",
    });
  }
};