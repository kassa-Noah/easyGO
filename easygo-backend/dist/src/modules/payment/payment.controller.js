"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.simulatePayment = exports.listBookingPayments = exports.getPayment = exports.initiatePayment = void 0;
const payment_service_1 = require("./payment.service");
const payment_schema_1 = require("./payment.schema");
const initiatePayment = async (req, res) => {
    try {
        const validatedData = payment_schema_1.initiatePaymentSchema.parse(req.body);
        const booking = await (0, payment_service_1.getBookingForPayment)(validatedData.bookingId);
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
                message: "You are not authorized to pay for this booking",
            });
        }
        if (booking.status ===
            "CANCELLED") {
            return res.status(400).json({
                success: false,
                message: "A cancelled booking cannot be paid",
            });
        }
        if (booking.status ===
            "COMPLETED") {
            return res.status(400).json({
                success: false,
                message: "A completed booking cannot be paid",
            });
        }
        if (booking.trip.status !==
            "SCHEDULED") {
            return res.status(400).json({
                success: false,
                message: "Payment is only allowed for a scheduled trip",
            });
        }
        if (booking.trip.departureTime <=
            new Date()) {
            return res.status(400).json({
                success: false,
                message: "Payment cannot be made after the trip departure time",
            });
        }
        const successfulPayment = await (0, payment_service_1.getSuccessfulPaymentForBooking)(booking.id);
        if (successfulPayment) {
            return res.status(409).json({
                success: false,
                message: "This booking has already been paid",
            });
        }
        const pendingPayment = await (0, payment_service_1.getPendingPaymentForBooking)(booking.id);
        if (pendingPayment) {
            return res.status(409).json({
                success: false,
                message: "A payment is already pending for this booking",
            });
        }
        const payment = await (0, payment_service_1.createPayment)(validatedData);
        return res.status(201).json({
            success: true,
            message: "Payment initiated successfully",
            data: payment,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to initiate payment",
        });
    }
};
exports.initiatePayment = initiatePayment;
const getPayment = async (req, res) => {
    try {
        const payment = await (0, payment_service_1.getPaymentById)(String(req.params.id));
        if (!payment) {
            return res.status(404).json({
                success: false,
                message: "Payment not found",
            });
        }
        if (req.user.role ===
            "CUSTOMER" &&
            payment.booking.userId !==
                req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to view this payment",
            });
        }
        if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, payment_service_1.getAgencyStaffMembership)(req.user.userId, payment.booking.trip
                .agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this payment",
                });
            }
        }
        return res.status(200).json({
            success: true,
            data: payment,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve payment",
        });
    }
};
exports.getPayment = getPayment;
const listBookingPayments = async (req, res) => {
    try {
        const bookingId = String(req.params.bookingId);
        const booking = await (0, payment_service_1.getBookingForPayment)(bookingId);
        if (!booking) {
            return res.status(404).json({
                success: false,
                message: "Booking not found",
            });
        }
        if (req.user.role ===
            "CUSTOMER" &&
            booking.userId !==
                req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to view these payments",
            });
        }
        if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, payment_service_1.getAgencyStaffMembership)(req.user.userId, booking.trip.agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view these payments",
                });
            }
        }
        const payments = await (0, payment_service_1.getPaymentsByBookingId)(bookingId);
        return res.status(200).json({
            success: true,
            count: payments.length,
            data: payments,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve payments",
        });
    }
};
exports.listBookingPayments = listBookingPayments;
const simulatePayment = async (req, res) => {
    try {
        const paymentId = String(req.params.id);
        const payment = await (0, payment_service_1.getPaymentById)(paymentId);
        if (!payment) {
            return res.status(404).json({
                success: false,
                message: "Payment not found",
            });
        }
        if (payment.booking.userId !==
            req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to process this payment",
            });
        }
        const validatedData = payment_schema_1.simulatePaymentSchema.parse(req.body);
        const updatedPayment = await (0, payment_service_1.completeSimulatedPayment)(paymentId, validatedData.result);
        return res.status(200).json({
            success: true,
            message: validatedData.result ===
                "SUCCESSFUL"
                ? "Payment completed successfully"
                : "Payment failed",
            data: updatedPayment,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to process payment",
        });
    }
};
exports.simulatePayment = simulatePayment;
//# sourceMappingURL=payment.controller.js.map