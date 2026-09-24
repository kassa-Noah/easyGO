"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.editTrip = exports.addTrip = exports.getTrip = exports.listTrips = void 0;
const trip_service_1 = require("./trip.service");
const trip_schema_1 = require("./trip.schema");
const canManageAgencyTrips = async (userId, role, agencyId) => {
    if (role === "ADMIN") {
        return true;
    }
    if (role !== "AGENCY_STAFF") {
        return false;
    }
    const membership = await (0, trip_service_1.getAgencyStaffMembership)(userId, agencyId);
    return !!membership;
};
const listTrips = async (_req, res) => {
    try {
        const trips = await (0, trip_service_1.getAllTrips)();
        return res.status(200).json({
            success: true,
            data: trips,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve trips",
        });
    }
};
exports.listTrips = listTrips;
const getTrip = async (req, res) => {
    try {
        const tripId = String(req.params.id);
        const trip = await (0, trip_service_1.getTripById)(tripId);
        if (!trip) {
            return res.status(404).json({
                success: false,
                message: "Trip not found",
            });
        }
        return res.status(200).json({
            success: true,
            data: trip,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve trip",
        });
    }
};
exports.getTrip = getTrip;
const addTrip = async (req, res) => {
    try {
        const validatedData = trip_schema_1.createTripSchema.parse(req.body);
        const allowed = await canManageAgencyTrips(req.user.userId, req.user.role, validatedData.agencyId);
        if (!allowed) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to create trips for this agency",
            });
        }
        const agency = await (0, trip_service_1.getAgencyById)(validatedData.agencyId);
        if (!agency) {
            return res.status(404).json({
                success: false,
                message: "Agency not found",
            });
        }
        const route = await (0, trip_service_1.getRouteById)(validatedData.routeId);
        if (!route) {
            return res.status(404).json({
                success: false,
                message: "Route not found",
            });
        }
        if (route.originBranch.agencyId !==
            validatedData.agencyId ||
            route.destinationBranch.agencyId !==
                validatedData.agencyId) {
            return res.status(400).json({
                success: false,
                message: "The selected route does not belong to this agency",
            });
        }
        if (validatedData.vehicleId) {
            const vehicle = await (0, trip_service_1.getVehicleById)(validatedData.vehicleId);
            if (!vehicle) {
                return res.status(404).json({
                    success: false,
                    message: "Vehicle not found",
                });
            }
            if (vehicle.agencyId !== validatedData.agencyId) {
                return res.status(400).json({
                    success: false,
                    message: "Vehicle does not belong to this agency",
                });
            }
            if (validatedData.totalSeats >
                vehicle.capacity) {
                return res.status(400).json({
                    success: false,
                    message: "Trip seats cannot exceed vehicle capacity",
                });
            }
        }
        const departure = new Date(validatedData.departureTime);
        if (departure <= new Date()) {
            return res.status(400).json({
                success: false,
                message: "Departure time must be in the future",
            });
        }
        if (validatedData.arrivalTime) {
            const arrival = new Date(validatedData.arrivalTime);
            if (arrival <= departure) {
                return res.status(400).json({
                    success: false,
                    message: "Arrival time must be after departure time",
                });
            }
        }
        const trip = await (0, trip_service_1.createTrip)(validatedData);
        return res.status(201).json({
            success: true,
            message: "Trip created successfully",
            data: trip,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to create trip",
        });
    }
};
exports.addTrip = addTrip;
const editTrip = async (req, res) => {
    try {
        const tripId = String(req.params.id);
        const existingTrip = await (0, trip_service_1.getTripById)(tripId);
        if (!existingTrip) {
            return res.status(404).json({
                success: false,
                message: "Trip not found",
            });
        }
        const allowed = await canManageAgencyTrips(req.user.userId, req.user.role, existingTrip.agencyId);
        if (!allowed) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to manage this trip",
            });
        }
        const validatedData = trip_schema_1.updateTripSchema.parse(req.body);
        if (validatedData.vehicleId) {
            const vehicle = await (0, trip_service_1.getVehicleById)(validatedData.vehicleId);
            if (!vehicle) {
                return res.status(404).json({
                    success: false,
                    message: "Vehicle not found",
                });
            }
            if (vehicle.agencyId !== existingTrip.agencyId) {
                return res.status(400).json({
                    success: false,
                    message: "Vehicle does not belong to this agency",
                });
            }
        }
        const trip = await (0, trip_service_1.updateTrip)(tripId, validatedData);
        return res.status(200).json({
            success: true,
            message: "Trip updated successfully",
            data: trip,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to update trip",
        });
    }
};
exports.editTrip = editTrip;
//# sourceMappingURL=trip.controller.js.map