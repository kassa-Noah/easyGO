"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.searchTrips = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const searchTrips = async (data) => {
    const startOfDay = new Date(`${data.travelDate}T00:00:00.000Z`);
    const endOfDay = new Date(`${data.travelDate}T23:59:59.999Z`);
    const trips = await prisma_1.default.trip.findMany({
        where: {
            departureTime: {
                gte: startOfDay,
                lte: endOfDay,
            },
            status: "SCHEDULED",
            availableSeats: {
                gt: 0,
            },
            ...(data.agencyId && {
                agencyId: data.agencyId,
            }),
            route: {
                is: {
                    isActive: true,
                    originBranch: {
                        is: {
                            city: {
                                equals: data.originCity,
                                mode: "insensitive",
                            },
                            isActive: true,
                        },
                    },
                    destinationBranch: {
                        is: {
                            city: {
                                equals: data.destinationCity,
                                mode: "insensitive",
                            },
                            isActive: true,
                        },
                    },
                },
            },
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
        orderBy: {
            departureTime: "asc",
        },
    });
    return trips;
};
exports.searchTrips = searchTrips;
//# sourceMappingURL=search.service.js.map