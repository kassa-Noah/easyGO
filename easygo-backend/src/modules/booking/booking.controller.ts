import {
  Request,
  Response,
} from "express";

import {
  cancelBooking,
  createBooking,
  getAgencyStaffMembership,
  getBookingById,
  getTripForBooking,
  getUserBookings,
} from "./booking.service";

import {
  createBookingSchema,
} from "./booking.schema";

export const addBooking = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData =
      createBookingSchema.parse(
        req.body
      );

    const trip =
      await getTripForBooking(
        validatedData.tripId
      );

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    if (trip.status !== "SCHEDULED") {
      return res.status(400).json({
        success: false,
        message:
          "Only scheduled trips can be booked",
      });
    }

    if (
      trip.departureTime <= new Date()
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Past trips cannot be booked",
      });
    }

    if (
      trip.availableSeats <
      validatedData.numberOfSeats
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Not enough seats are available",
      });
    }

    const booking =
      await createBooking({
        userId:
          req.user!.userId,

        tripId:
          validatedData.tripId,

        numberOfSeats:
          validatedData.numberOfSeats,
      });

    return res.status(201).json({
      success: true,
      message:
        "Booking created successfully",
      data: booking,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to create booking",
    });
  }
};

export const listMyBookings = async (
  req: Request,
  res: Response
) => {
  try {
    const bookings =
      await getUserBookings(
        req.user!.userId
      );

    return res.status(200).json({
      success: true,
      count: bookings.length,
      data: bookings,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve bookings",
    });
  }
};

export const getBooking = async (
  req: Request,
  res: Response
) => {
  try {
    const bookingId = String(
      req.params.id
    );

    const booking =
      await getBookingById(
        bookingId
      );

    if (!booking) {
      return res.status(404).json({
        success: false,
        message:
          "Booking not found",
      });
    }

    if (
      req.user!.role === "CUSTOMER"
    ) {
      if (
        booking.userId !==
        req.user!.userId
      ) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to view this booking",
        });
      }
    } else if (
      req.user!.role ===
      "AGENCY_STAFF"
    ) {
      const membership =
        await getAgencyStaffMembership(
          req.user!.userId,
          booking.trip.agencyId
        );

      if (!membership) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to view this booking",
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve booking",
    });
  }
};

export const cancelMyBooking =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const bookingId = String(
        req.params.id
      );

      const booking =
        await getBookingById(
          bookingId
        );

      if (!booking) {
        return res.status(404).json({
          success: false,
          message:
            "Booking not found",
        });
      }

      if (
        booking.userId !==
        req.user!.userId
      ) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to cancel this booking",
        });
      }

      const cancelled =
        await cancelBooking(
          bookingId
        );

      return res.status(200).json({
        success: true,
        message:
          "Booking cancelled successfully",
        data: cancelled,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message:
          error.message ||
          "Unable to cancel booking",
      });
    }
  };
