import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";

import {
  completeSimulatedPayment,
  createPayment,
  getAgencyStaffMembership,
  getBookingForPayment,
  getPaymentById,
  getPaymentsByBookingId,
  getPendingPaymentForBooking,
  getSuccessfulPaymentForBooking,
} from "./payment.service";

import {
  initiatePaymentSchema,
  simulatePaymentSchema,
} from "./payment.schema";

import {
  requestFirstMileTaxiAssignment,
} from "../taxi/taxi.service";

import {
  getBookingById,
} from "../booking/booking.service";

import {
  notifySafely,
} from "../notification/notification.service";

export const initiatePayment =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const validatedData =
        initiatePaymentSchema.parse(
          req.body
        );

      const booking =
        await getBookingForPayment(
          validatedData.bookingId
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
            "You are not authorized to pay for this booking",
        });
      }

      if (
        booking.status ===
        "CANCELLED"
      ) {
        return res.status(400).json({
          success: false,

          message:
            "A cancelled booking cannot be paid",
        });
      }

      if (
        booking.status ===
        "COMPLETED"
      ) {
        return res.status(400).json({
          success: false,

          message:
            "A completed booking cannot be paid",
        });
      }

      if (
        booking.trip.status !==
        "SCHEDULED"
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Payment is only allowed for a scheduled trip",
        });
      }

      if (
        booking.trip.departureTime <=
        new Date()
      ) {
        return res.status(400).json({
          success: false,

          message:
            "Payment cannot be made after the trip departure time",
        });
      }

      const successfulPayment =
        await getSuccessfulPaymentForBooking(
          booking.id
        );

      if (successfulPayment) {
        return res.status(409).json({
          success: false,

          message:
            "This booking has already been paid",
        });
      }

      const pendingPayment =
        await getPendingPaymentForBooking(
          booking.id
        );

      if (pendingPayment) {
        return res.status(409).json({
          success: false,

          message:
            "A payment is already pending for this booking",
        });
      }

      const payment =
        await createPayment(
          validatedData
        );

      return res.status(201).json({
        success: true,

        message:
          "Payment initiated successfully",

        data:
          payment,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to initiate payment",
      });
    }
  };

export const getPayment =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const payment =
        await getPaymentById(
          String(
            req.params.id
          )
        );

      if (!payment) {
        return res.status(404).json({
          success: false,

          message:
            "Payment not found",
        });
      }

      if (
        req.user!.role ===
          "CUSTOMER" &&
        payment.booking.userId !==
          req.user!.userId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "You are not authorized to view this payment",
        });
      }

      if (
        req.user!.role ===
        "AGENCY_STAFF"
      ) {
        const membership =
          await getAgencyStaffMembership(
            req.user!.userId,
            payment.booking.trip
              .agencyId
          );

        if (!membership) {
          return res.status(403).json({
            success: false,

            message:
              "You are not authorized to view this payment",
          });
        }
      }

      return res.status(200).json({
        success: true,
        data:
          payment,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve payment",
      });
    }
  };

export const listBookingPayments =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const bookingId =
        String(
          req.params.bookingId
        );

      const booking =
        await getBookingForPayment(
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
        req.user!.role ===
          "CUSTOMER" &&
        booking.userId !==
          req.user!.userId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "You are not authorized to view these payments",
        });
      }

      if (
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
              "You are not authorized to view these payments",
          });
        }
      }

      const payments =
        await getPaymentsByBookingId(
          bookingId
        );

      return res.status(200).json({
        success: true,

        count:
          payments.length,

        data:
          payments,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve payments",
      });
    }
  };

export const simulatePayment =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const paymentId =
        String(
          req.params.id
        );

      const payment =
        await getPaymentById(
          paymentId
        );

      if (!payment) {
        return res.status(404).json({
          success: false,

          message:
            "Payment not found",
        });
      }

      if (
        payment.booking.userId !==
        req.user!.userId
      ) {
        return res.status(403).json({
          success: false,

          message:
            "You are not authorized to process this payment",
        });
      }

      const validatedData =
        simulatePaymentSchema.parse(
          req.body
        );

      const updatedPayment =
        await completeSimulatedPayment(
          paymentId,
          validatedData.result
        );

      // Requesting the first-mile ride is a separate operational
      // step that follows settlement. A mock taxi provider failure
      // must never invalidate a payment that has already been
      // taken, so the failure is logged and the settlement result
      // is still returned to the customer.
      if (
        updatedPayment?.status ===
        "SUCCESSFUL"
      ) {
        try {
          await requestFirstMileTaxiAssignment(
            updatedPayment.bookingId
          );
        } catch (error) {
          console.error(
            "Unable to request the first-mile taxi assignment:",
            error
          );
        }

        // The customer has just paid, so their seat is confirmed and they
        // should be able to see that without reloading the booking.
        const booking = await getBookingById(
          updatedPayment.bookingId
        );

        if (booking) {
          await notifySafely({
            userId: booking.userId,

            title: "Booking confirmed",

            message:
              `Your booking ${booking.bookingReference} is confirmed. ` +
              `Open it to see your ticket and your pickup details.`,

            type: "BOOKING",
          });
        }
      }

      return res.status(200).json({
        success: true,

        message:
          validatedData.result ===
          "SUCCESSFUL"
            ? "Payment completed successfully"
            : "Payment failed",

        data:
          updatedPayment,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to process payment",
      });
    }
  };