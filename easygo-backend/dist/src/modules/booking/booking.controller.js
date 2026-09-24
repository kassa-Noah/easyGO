"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cancelMyBooking = exports.getBooking = exports.listMyBookings = exports.addBooking = void 0;
const booking_service_1 = require("./booking.service");
const booking_schema_1 = require("./booking.schema");
const addBooking = async (req, res) => {
    try {
        const validatedData = booking_schema_1.createBookingSchema.parse(req.body);
        const trip = await (0, booking_service_1.getTripForBooking)(validatedData.tripId);
        if (!trip) {
            return res.status(404).json({
                success: false,
                message: "Trip not found",
            });
        }
        if (trip.status !== "SCHEDULED") {
            return res.status(400).json({
                success: false,
                message: "Only scheduled trips can be booked",
            });
        }
        if (trip.departureTime <= new Date()) {
            return res.status(400).json({
                success: false,
                message: "Past trips cannot be booked",
            });
        }
        if (trip.availableSeats <
            validatedData.numberOfSeats) {
            return res.status(400).json({
                success: false,
                message: "Not enough seats are available",
            });
        }
        const booking = await (0, booking_service_1.createBooking)({
            userId: req.user.userId,
            tripId: validatedData.tripId,
            numberOfSeats: validatedData.numberOfSeats,
        });
        return res.status(201).json({
            success: true,
            message: "Booking created successfully",
            data: booking,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to create booking",
        });
    }
};
exports.addBooking = addBooking;
const listMyBookings = async (req, res) => {
    try {
        const bookings = await (0, booking_service_1.getUserBookings)(req.user.userId);
        return res.status(200).json({
            success: true,
            count: bookings.length,
            data: bookings,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve bookings",
        });
    }
};
exports.listMyBookings = listMyBookings;
const getBooking = async (req, res) => {
    try {
        const bookingId = String(req.params.id);
        const booking = await (0, booking_service_1.getBookingById)(bookingId);
        if (!booking) {
            return res.status(404).json({
                success: false,
                message: "Booking not found",
            });
        }
        if (req.user.role === "CUSTOMER") {
            if (booking.userId !==
                req.user.userId) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this booking",
                });
            }
        }
        else if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, booking_service_1.getAgencyStaffMembership)(req.user.userId, booking.trip.agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this booking",
                });
            }
        }
        return res.status(200).json({
            success: true,
            data: booking,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve booking",
        });
    }
};
exports.getBooking = getBooking;
const cancelMyBooking = async (req, res) => {
    try {
        const bookingId = String(req.params.id);
        const booking = await (0, booking_service_1.getBookingById)(bookingId);
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
                message: "You are not authorized to cancel this booking",
            });
        }
        const cancelled = await (0, booking_service_1.cancelBooking)(bookingId);
        return res.status(200).json({
            success: true,
            message: "Booking cancelled successfully",
            data: cancelled,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to cancel booking",
        });
    }
};
exports.cancelMyBooking = cancelMyBooking;
//# sourceMappingURL=booking.controller.js.map