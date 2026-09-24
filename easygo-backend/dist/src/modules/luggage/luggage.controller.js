"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.changeLuggageStatus = exports.trackLuggage = exports.getLuggage = exports.listMyLuggage = exports.registerLuggage = void 0;
const luggage_service_1 = require("./luggage.service");
const luggage_schema_1 = require("./luggage.schema");
const registerLuggage = async (req, res) => {
    try {
        const validatedData = luggage_schema_1.createLuggageSchema.parse(req.body);
        const booking = await (0, luggage_service_1.getBookingForLuggage)(validatedData.bookingId);
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
                message: "You are not authorized to register luggage for this booking",
            });
        }
        if (booking.status !==
            "CONFIRMED") {
            return res.status(400).json({
                success: false,
                message: "Luggage can only be registered for a confirmed booking",
            });
        }
        const luggage = await (0, luggage_service_1.createLuggage)(validatedData);
        return res.status(201).json({
            success: true,
            message: "Luggage registered successfully",
            data: luggage,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to register luggage",
        });
    }
};
exports.registerLuggage = registerLuggage;
const listMyLuggage = async (req, res) => {
    try {
        const luggage = await (0, luggage_service_1.getUserLuggage)(req.user.userId);
        return res.status(200).json({
            success: true,
            count: luggage.length,
            data: luggage,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve luggage",
        });
    }
};
exports.listMyLuggage = listMyLuggage;
const getLuggage = async (req, res) => {
    try {
        const luggage = await (0, luggage_service_1.getLuggageById)(String(req.params.id));
        if (!luggage) {
            return res.status(404).json({
                success: false,
                message: "Luggage not found",
            });
        }
        if (req.user.role ===
            "CUSTOMER" &&
            luggage.booking.userId !==
                req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to view this luggage",
            });
        }
        if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, luggage_service_1.getAgencyStaffMembership)(req.user.userId, luggage.booking.trip
                .agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this luggage",
                });
            }
        }
        return res.status(200).json({
            success: true,
            data: luggage,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve luggage",
        });
    }
};
exports.getLuggage = getLuggage;
const trackLuggage = async (req, res) => {
    try {
        const luggage = await (0, luggage_service_1.getLuggageByTrackingNumber)(String(req.params.trackingNumber));
        if (!luggage) {
            return res.status(404).json({
                success: false,
                message: "Luggage tracking number not found",
            });
        }
        if (luggage.booking.userId !==
            req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to track this luggage",
            });
        }
        return res.status(200).json({
            success: true,
            data: luggage,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to track luggage",
        });
    }
};
exports.trackLuggage = trackLuggage;
const changeLuggageStatus = async (req, res) => {
    try {
        const luggageId = String(req.params.id);
        const luggage = await (0, luggage_service_1.getLuggageById)(luggageId);
        if (!luggage) {
            return res.status(404).json({
                success: false,
                message: "Luggage not found",
            });
        }
        if (req.user.role ===
            "AGENCY_STAFF") {
            const membership = await (0, luggage_service_1.getAgencyStaffMembership)(req.user.userId, luggage.booking.trip
                .agencyId);
            if (!membership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to update this luggage",
                });
            }
        }
        const validatedData = luggage_schema_1.updateLuggageStatusSchema.parse(req.body);
        const updatedLuggage = await (0, luggage_service_1.updateLuggageStatus)({
            luggageId,
            status: validatedData.status,
            location: validatedData.location,
            description: validatedData.description,
            updatedById: req.user.userId,
        });
        return res.status(200).json({
            success: true,
            message: "Luggage status updated successfully",
            data: updatedLuggage,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to update luggage status",
        });
    }
};
exports.changeLuggageStatus = changeLuggageStatus;
//# sourceMappingURL=luggage.controller.js.map