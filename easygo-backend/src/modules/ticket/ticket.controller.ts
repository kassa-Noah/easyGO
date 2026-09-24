import {
  Request,
  Response,
} from "express";

import {
  createTicket,
  getAgencyStaffMembership,
  getBookingForTicket,
  getTicketByBookingId,
  getTicketById,
  getTicketByNumber,
  getUserTickets,
} from "./ticket.service";

import {
  createTicketSchema,
} from "./ticket.schema";

export const generateTicket = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData =
      createTicketSchema.parse(
        req.body
      );

    const booking =
      await getBookingForTicket(
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
          "You are not authorized to generate a ticket for this booking",
      });
    }

    if (
      booking.status !==
      "CONFIRMED"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Only confirmed bookings can receive a ticket",
      });
    }

    const successfulPayment =
      booking.payments.find(
        (payment) =>
          payment.status ===
          "SUCCESSFUL"
      );

    if (!successfulPayment) {
      return res.status(400).json({
        success: false,
        message:
          "A successful payment is required before ticket generation",
      });
    }

    if (booking.ticket) {
      return res.status(409).json({
        success: false,
        message:
          "A ticket already exists for this booking",
      });
    }

    const ticket =
      await createTicket(
        booking.id
      );

    return res.status(201).json({
      success: true,
      message:
        "Digital ticket generated successfully",
      data: ticket,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to generate digital ticket",
    });
  }
};

export const listMyTickets = async (
  req: Request,
  res: Response
) => {
  try {
    const tickets =
      await getUserTickets(
        req.user!.userId
      );

    return res.status(200).json({
      success: true,
      count: tickets.length,
      data: tickets,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve tickets",
    });
  }
};

export const getTicket = async (
  req: Request,
  res: Response
) => {
  try {
    const ticketId = String(
      req.params.id
    );

    const ticket =
      await getTicketById(
        ticketId
      );

    if (!ticket) {
      return res.status(404).json({
        success: false,
        message:
          "Ticket not found",
      });
    }

    if (
      req.user!.role ===
      "CUSTOMER"
    ) {
      if (
        ticket.booking.userId !==
        req.user!.userId
      ) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to view this ticket",
        });
      }
    } else if (
      req.user!.role ===
      "AGENCY_STAFF"
    ) {
      const membership =
        await getAgencyStaffMembership(
          req.user!.userId,
          ticket.booking.trip
            .agencyId
        );

      if (!membership) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to view this ticket",
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve ticket",
    });
  }
};

export const getBookingTicket =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const bookingId = String(
        req.params.bookingId
      );

      const ticket =
        await getTicketByBookingId(
          bookingId
        );

      if (!ticket) {
        return res.status(404).json({
          success: false,
          message:
            "Ticket not found for this booking",
        });
      }

      if (
        req.user!.role ===
        "CUSTOMER"
      ) {
        if (
          ticket.booking.userId !==
          req.user!.userId
        ) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to view this ticket",
          });
        }
      } else if (
        req.user!.role ===
        "AGENCY_STAFF"
      ) {
        const membership =
          await getAgencyStaffMembership(
            req.user!.userId,
            ticket.booking.trip
              .agencyId
          );

        if (!membership) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to view this ticket",
          });
        }
      }

      return res.status(200).json({
        success: true,
        data: ticket,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,
        message:
          error.message ||
          "Unable to retrieve ticket",
      });
    }
  };

export const verifyTicket = async (
  req: Request,
  res: Response
) => {
  try {
    const ticketNumber = String(
      req.params.ticketNumber
    );

    const ticket =
      await getTicketByNumber(
        ticketNumber
      );

    if (!ticket) {
      return res.status(404).json({
        success: false,
        message:
          "Ticket not found",
      });
    }

    if (
      req.user!.role ===
      "AGENCY_STAFF"
    ) {
      const membership =
        await getAgencyStaffMembership(
          req.user!.userId,
          ticket.booking.trip
            .agencyId
        );

      if (!membership) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to verify this ticket",
        });
      }
    }

    return res.status(200).json({
      success: true,

      message:
        ticket.status === "ACTIVE"
          ? "Ticket is valid"
          : `Ticket status is ${ticket.status}`,

      data: ticket,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to verify ticket",
    });
  }
};