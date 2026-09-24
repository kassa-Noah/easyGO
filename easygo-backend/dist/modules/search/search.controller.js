"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.searchAvailableTrips = void 0;
const search_schema_1 = require("./search.schema");
const search_service_1 = require("./search.service");
const searchAvailableTrips = async (req, res) => {
    try {
        const validatedData = search_schema_1.searchTripsSchema.parse(req.query);
        if (validatedData.originCity.toLowerCase() ===
            validatedData.destinationCity.toLowerCase()) {
            return res.status(400).json({
                success: false,
                message: "Origin and destination cities must be different",
            });
        }
        const trips = await (0, search_service_1.searchTrips)(validatedData);
        return res.status(200).json({
            success: true,
            message: trips.length > 0
                ? "Available trips found"
                : "No available trips found",
            count: trips.length,
            data: trips,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Trip search failed",
        });
    }
};
exports.searchAvailableTrips = searchAvailableTrips;
//# sourceMappingURL=search.controller.js.map