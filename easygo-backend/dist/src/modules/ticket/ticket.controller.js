"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyTicket = exports.getBookingTicket = exports.getTicket = exports.listMyTickets = exports.generateTicket = void 0;
const ticket_service_1 = require("./ticket.service");
const ticket_schema_1 = require("./ticket.schema");
const generateTicket = async (req, res) => {
    try {
        const validatedData = ticket_schema_1.createTicketSchema.parse(req.body);
        const booking = await (0, ticket_service_1.getBookingForTicket)(validatedData.bookingId);
        if (!booking) {
            return res.status(404).json({
                success: false,
                message: "Booking not found",
            });
        }
        if (booking.userId !==
            req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to generate a ticket for this booking",
            });
        }
        if (booking.status !==
            "CONFIRMED") {
            return res.status(400).json({
                success: false,
                message: "Only confirmed bookings can receive a ticket",
            });
        }
        const successfulPayment = booking.payments.find((payment) => payment.status ===
            "SUCCESSFUL");
        if (!successfulPayment) {
            return res.status(400).json({
                success: false,
                message: "A successful payment is required before ticket generation",
            });
        }
        if (booking.ticket) {
            return res.status(409).json({
                success: false,
                message: "A ticket already exists for this booking",
            });
        }
        const ticket = await (0, ticket_service_1.createTicket)(booking.id);
        return res.status(201).json({
            success: true,
            message: "Digital ticket generated successfully",
            data: ticket,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to generate digital ticket",
        });
    }
};
exports.generateTicket = generateTicket;
const listMyTickets = async (req, res) => {
    try {
        const tickets = await (0, ticket_service_1.getUserTickets)(req.user.userId);
        return res.status(200).json({
            success: true,
            count: tickets.length,
            data: tickets,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve tickets",
        });
    }
};
exports.listMyTickets = listMyTickets;
const getTicket = async (req, res) => {
    try {
        const ticketId = String(req.params.id);
        const ticket = await (0, ticket_service_1.getTicketById)(ticketId);
        if (!ticket) {
            return res.status(404).json({
                success: false,
                message: "Ticket not found",
            });
        }
        if (req.user.role ===
            "CUSTOMER") {
            if (ticket.booking.userId !==
                req.user.userId) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this ticket",
                });
            }
        }
        else if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, ticket_service_1.getAgencyStaffMembership)(req.user.userId, ticket.booking.trip
                .agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this ticket",
                });
            }
        }
        return res.status(200).json({
            success: true,
            data: ticket,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve ticket",
        });
    }
};
exports.getTicket = getTicket;
const getBookingTicket = async (req, res) => {
    try {
        const bookingId = String(req.params.bookingId);
        const ticket = await (0, ticket_service_1.getTicketByBookingId)(bookingId);
        if (!ticket) {
            return res.status(404).json({
                success: false,
                message: "Ticket not found for this booking",
            });
        }
        if (req.user.role ===
            "CUSTOMER") {
            if (ticket.booking.userId !==
                req.user.userId) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this ticket",
                });
            }
        }
        else if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, ticket_service_1.getAgencyStaffMembership)(req.user.userId, ticket.booking.trip
                .agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this ticket",
                });
            }
        }
        return res.status(200).json({
            success: true,
            data: ticket,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve ticket",
        });
    }
};
exports.getBookingTicket = getBookingTicket;
const verifyTicket = async (req, res) => {
    try {
        const ticketNumber = String(req.params.ticketNumber);
        const ticket = await (0, ticket_service_1.getTicketByNumber)(ticketNumber);
        if (!ticket) {
            return res.status(404).json({
                success: false,
                message: "Ticket not found",
            });
        }
        if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, ticket_service_1.getAgencyStaffMembership)(req.user.userId, ticket.booking.trip
                .agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to verify this ticket",
                });
            }
        }
        return res.status(200).json({
            success: true,
            message: ticket.status === "ACTIVE"
                ? "Ticket is valid"
                : `Ticket status is ${ticket.status}`,
            data: ticket,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to verify ticket",
        });
    }
};
exports.verifyTicket = verifyTicket;
//# sourceMappingURL=ticket.controller.js.map