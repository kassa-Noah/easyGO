"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateJourneyStatus = exports.getUserJourneys = exports.getJourneyById = exports.createJourney = exports.getBookingForJourney = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getBookingForJourney = async (bookingId) => {
    return prisma_1.default.booking.findUnique({
        where: {
            id: bookingId,
        },
        include: {
            trip: {
                include: {
                    agency: true,
                    route: {
                        include: {
                            originBranch: true,
                            destinationBranch: true,
                        },
                    },
                },
            },
            journey: true,
        },
    });
};
exports.getBookingForJourney = getBookingForJourney;
const createJourney = async (userId, data) => {
    return prisma_1.default.doorToDoorJourney.create({
        data: {
            userId,
            bookingId: data.bookingId,
            pickupAddress: data.pickupAddress,
            pickupLatitude: data.pickupLatitude,
            pickupLongitude: data.pickupLongitude,
            destinationAddress: data.destinationAddress,
            destinationLatitude: data.destinationLatitude,
            destinationLongitude: data.destinationLongitude,
        },
        include: {
            booking: {
                include: {
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                        },
                    },
                },
            },
            taxiAssignments: {
                include: {
                    provider: true,
                },
            },
        },
    });
};
exports.createJourney = createJourney;
const getJourneyById = async (journeyId) => {
    return prisma_1.default.doorToDoorJourney.findUnique({
        where: {
            id: journeyId,
        },
        include: {
            booking: {
                include: {
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                        },
                    },
                    payments: true,
                    ticket: true,
                    luggage: true,
                },
            },
            taxiAssignments: {
                include: {
                    provider: true,
                },
            },
        },
    });
};
exports.getJourneyById = getJourneyById;
const getUserJourneys = async (userId) => {
    return prisma_1.default.doorToDoorJourney.findMany({
        where: {
            userId,
        },
        include: {
            booking: {
                include: {
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                        },
                    },
                },
            },
            taxiAssignments: {
                include: {
                    provider: true,
                },
            },
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getUserJourneys = getUserJourneys;
const updateJourneyStatus = async (journeyId, status) => {
    return prisma_1.default.doorToDoorJourney.update({
        where: {
            id: journeyId,
        },
        data: {
            status,
        },
        include: {
            booking: {
                include: {
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                        },
                    },
                },
            },
            taxiAssignments: {
                include: {
                    provider: true,
                },
            },
        },
    });
};
exports.updateJourneyStatus = updateJourneyStatus;
//# sourceMappingURL=journey.service.js.map