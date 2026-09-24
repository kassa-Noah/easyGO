"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.changeJourneyStatus = exports.getJourney = exports.listMyJourneys = exports.addJourney = void 0;
const journey_service_1 = require("./journey.service");
const journey_schema_1 = require("./journey.schema");
const addJourney = async (req, res) => {
    try {
        const validatedData = journey_schema_1.createJourneySchema.parse(req.body);
        const booking = await (0, journey_service_1.getBookingForJourney)(validatedData.bookingId);
        if (!booking) {
            return res.status(404).json({
                success: false,
                message: "Booking not found",
            });
        }
        if (booking.userId !== req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to create a journey for this booking",
            });
        }
        if (booking.journey) {
            return res.status(409).json({
                success: false,
                message: "A door-to-door journey already exists for this booking",
            });
        }
        if (booking.status === "CANCELLED") {
            return res.status(400).json({
                success: false,
                message: "A journey cannot be created for a cancelled booking",
            });
        }
        if (booking.trip.status === "CANCELLED") {
            return res.status(400).json({
                success: false,
                message: "A journey cannot be created for a cancelled trip",
            });
        }
        const journey = await (0, journey_service_1.createJourney)(req.user.userId, validatedData);
        return res.status(201).json({
            success: true,
            message: "Door-to-door journey created successfully",
            data: journey,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to create door-to-door journey",
        });
    }
};
exports.addJourney = addJourney;
const listMyJourneys = async (req, res) => {
    try {
        const journeys = await (0, journey_service_1.getUserJourneys)(req.user.userId);
        return res.status(200).json({
            success: true,
            count: journeys.length,
            data: journeys,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve journeys",
        });
    }
};
exports.listMyJourneys = listMyJourneys;
const getJourney = async (req, res) => {
    try {
        const journeyId = String(req.params.id);
        const journey = await (0, journey_service_1.getJourneyById)(journeyId);
        if (!journey) {
            return res.status(404).json({
                success: false,
                message: "Journey not found",
            });
        }
        if (req.user.role === "CUSTOMER" &&
            journey.userId !== req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to view this journey",
            });
        }
        return res.status(200).json({
            success: true,
            data: journey,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve journey",
        });
    }
};
exports.getJourney = getJourney;
const changeJourneyStatus = async (req, res) => {
    try {
        const journeyId = String(req.params.id);
        const existingJourney = await (0, journey_service_1.getJourneyById)(journeyId);
        if (!existingJourney) {
            return res.status(404).json({
                success: false,
                message: "Journey not found",
            });
        }
        const validatedData = journey_schema_1.updateJourneyStatusSchema.parse(req.body);
        const journey = await (0, journey_service_1.updateJourneyStatus)(journeyId, validatedData.status);
        return res.status(200).json({
            success: true,
            message: "Journey status updated successfully",
            data: journey,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to update journey status",
        });
    }
};
exports.changeJourneyStatus = changeJourneyStatus;
//# sourceMappingURL=journey.controller.js.map