import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";
import { listAgencyStaffUserIds } from "../../lib/agency-staff";
import { notifySafely } from "../notification/notification.service";

import {
  cancelBooking,
  createBooking,
  getAgencyStaffMembership,
  getBookingById,
  getTripForBooking,
  getUserBookings,
  updateBookingStatus,
} from "./booking.service";

import {
  createBookingSchema,
  updateBookingStatusSchema,
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

    // A booking is the platform's central event and it used to tell nobody: the
    // agency found out by refreshing its bookings list, and the customer had to
    // remember to go and pay. Both sides are told now, and neither notification
    // can fail the booking that has already been stored.
    const route =
      `${trip.route.originBranch.city} → ` +
      `${trip.route.destinationBranch.city}`;

    const staffIds = await listAgencyStaffUserIds(
      trip.agencyId
    );

    for (const staffId of staffIds) {
      await notifySafely({
        userId: staffId,

        title: "New booking",

        message:
          `${booking.bookingReference} booked ` +
          `${booking.numberOfSeats} ` +
          `${booking.numberOfSeats === 1 ? "seat" : "seats"} on ` +
          `${route}. It is awaiting payment.`,

        type: "BOOKING",

        referenceType: "BOOKING",
        referenceId: booking.id,
      });
    }

    await notifySafely({
      userId: req.user!.userId,

      title: "Booking created",

      message:
        `Your booking ${booking.bookingReference} on ${route} is created. ` +
        `Pay for it to confirm your seat.`,

      type: "BOOKING",

      referenceType: "BOOKING",
      referenceId: booking.id,
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
        messageOf(error) ||
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
        messageOf(error) ||
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
        messageOf(error) ||
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

      // A cancellation frees a seat the agency was counting on, and it used to
      // happen silently.
      const staffIds = await listAgencyStaffUserIds(
        booking.trip.agencyId
      );

      for (const staffId of staffIds) {
        await notifySafely({
          userId: staffId,

          title: "Booking cancelled",

          message:
            `${booking.bookingReference} was cancelled by ` +
            `${booking.user.firstName} ${booking.user.lastName}. ` +
            `The seat is available again.`,

          type: "BOOKING",

          referenceType: "BOOKING",
          referenceId: booking.id,
        });
      }

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
          messageOf(error) ||
          "Unable to cancel booking",
      });
    }
  };

// Agency staff move a booking to a terminal state. The agency is
// verified against the trip's agency, and an administrator may act on
// any booking.
export const changeBookingStatus = async (
  req: Request,
  res: Response
) => {
  try {
    const bookingId = String(
      req.params.id
    );

    const booking = await getBookingById(
      bookingId
    );

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    if (
      req.user!.role === "AGENCY_STAFF"
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
            "You are not authorized to update this booking",
        });
      }
    }

    const validatedData =
      updateBookingStatusSchema.parse(
        req.body
      );

    const updated = await updateBookingStatus(
      bookingId,
      validatedData.status
    );

    return res.status(200).json({
      success: true,
      message:
        "Booking status updated successfully",
      data: updated,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to update booking status",
    });
  }
};
