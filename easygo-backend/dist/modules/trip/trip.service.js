"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateTrip = exports.createTrip = exports.getAgencyStaffMembership = exports.getVehicleById = exports.getRouteById = exports.getAgencyById = exports.getTripById = exports.getAllTrips = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getAllTrips = async () => {
    return prisma_1.default.trip.findMany({
        include: {
            agency: true,
            route: {
                include: {
                    originBranch: true,
                    destinationBranch: true,
                },
            },
            vehicle: true,
        },
        orderBy: {
            departureTime: "asc",
        },
    });
};
exports.getAllTrips = getAllTrips;
const getTripById = async (tripId) => {
    return prisma_1.default.trip.findUnique({
        where: {
            id: tripId,
        },
        include: {
            agency: true,
            route: {
                include: {
                    originBranch: true,
                    destinationBranch: true,
                },
            },
            vehicle: true,
        },
    });
};
exports.getTripById = getTripById;
const getAgencyById = async (agencyId) => {
    return prisma_1.default.agency.findUnique({
        where: {
            id: agencyId,
        },
    });
};
exports.getAgencyById = getAgencyById;
const getRouteById = async (routeId) => {
    return prisma_1.default.route.findUnique({
        where: {
            id: routeId,
        },
        include: {
            originBranch: true,
            destinationBranch: true,
        },
    });
};
exports.getRouteById = getRouteById;
const getVehicleById = async (vehicleId) => {
    return prisma_1.default.vehicle.findUnique({
        where: {
            id: vehicleId,
        },
    });
};
exports.getVehicleById = getVehicleById;
const getAgencyStaffMembership = async (userId, agencyId) => {
    return prisma_1.default.agencyStaff.findFirst({
        where: {
            userId,
            agencyId,
        },
    });
};
exports.getAgencyStaffMembership = getAgencyStaffMembership;
const createTrip = async (data) => {
    return prisma_1.default.trip.create({
        data: {
            departureTime: new Date(data.departureTime),
            arrivalTime: data.arrivalTime
                ? new Date(data.arrivalTime)
                : undefined,
            price: data.price,
            totalSeats: data.totalSeats,
            availableSeats: data.totalSeats,
            agencyId: data.agencyId,
            routeId: data.routeId,
            vehicleId: data.vehicleId,
        },
        include: {
            agency: true,
            route: true,
            vehicle: true,
        },
    });
};
exports.createTrip = createTrip;
const updateTrip = async (tripId, data) => {
    const updateData = {
        ...data,
    };
    if (data.departureTime) {
        updateData.departureTime = new Date(data.departureTime);
    }
    if (data.arrivalTime) {
        updateData.arrivalTime = new Date(data.arrivalTime);
    }
    return prisma_1.default.trip.update({
        where: {
            id: tripId,
        },
        data: updateData,
        include: {
            agency: true,
            route: true,
            vehicle: true,
        },
    });
};
exports.updateTrip = updateTrip;
//# sourceMappingURL=trip.service.js.map