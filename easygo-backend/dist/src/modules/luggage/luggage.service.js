"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAgencyStaffMembership = exports.updateLuggageStatus = exports.getUserLuggage = exports.getLuggageByTrackingNumber = exports.getLuggageById = exports.createLuggage = exports.getBookingForLuggage = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const generateTrackingNumber = () => {
    const timestamp = Date.now()
        .toString(36)
        .toUpperCase();
    const randomPart = Math.random()
        .toString(36)
        .substring(2, 8)
        .toUpperCase();
    return `LUG-${timestamp}-${randomPart}`;
};
const luggageProgress = {
    REGISTERED: 0,
    RECEIVED_AT_AGENCY: 15,
    LOADED: 30,
    IN_TRANSIT: 55,
    ARRIVED_AT_DESTINATION_AGENCY: 75,
    READY_FOR_COLLECTION: 90,
    DELIVERED: 100,
    LOST: 0,
};
const validLuggageTransitions = {
    REGISTERED: [
        "RECEIVED_AT_AGENCY",
        "LOST",
    ],
    RECEIVED_AT_AGENCY: [
        "LOADED",
        "LOST",
    ],
    LOADED: [
        "IN_TRANSIT",
        "LOST",
    ],
    IN_TRANSIT: [
        "ARRIVED_AT_DESTINATION_AGENCY",
        "LOST",
    ],
    ARRIVED_AT_DESTINATION_AGENCY: [
        "READY_FOR_COLLECTION",
        "LOST",
    ],
    READY_FOR_COLLECTION: [
        "DELIVERED",
        "LOST",
    ],
    DELIVERED: [],
    LOST: [],
};
const getBookingForLuggage = async (bookingId) => {
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
            luggage: true,
        },
    });
};
exports.getBookingForLuggage = getBookingForLuggage;
const createLuggage = async (data) => {
    return prisma_1.default.$transaction(async (tx) => {
        const trackingNumber = generateTrackingNumber();
        const luggage = await tx.luggage.create({
            data: {
                trackingNumber,
                description: data.description,
                weightKg: data.weightKg,
                status: "REGISTERED",
                progressPercentage: 0,
                bookingId: data.bookingId,
            },
        });
        await tx.luggageTrackingEvent.create({
            data: {
                status: "REGISTERED",
                progressPercentage: 0,
                description: "Luggage registered",
                luggageId: luggage.id,
            },
        });
        return tx.luggage.findUnique({
            where: {
                id: luggage.id,
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
                trackingEvents: {
                    orderBy: {
                        createdAt: "asc",
                    },
                },
            },
        });
    });
};
exports.createLuggage = createLuggage;
const getLuggageById = async (luggageId) => {
    return prisma_1.default.luggage.findUnique({
        where: {
            id: luggageId,
        },
        include: {
            booking: {
                include: {
                    user: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                            phone: true,
                        },
                    },
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
            trackingEvents: {
                orderBy: {
                    createdAt: "asc",
                },
            },
        },
    });
};
exports.getLuggageById = getLuggageById;
const getLuggageByTrackingNumber = async (trackingNumber) => {
    return prisma_1.default.luggage.findUnique({
        where: {
            trackingNumber,
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
            trackingEvents: {
                orderBy: {
                    createdAt: "asc",
                },
            },
        },
    });
};
exports.getLuggageByTrackingNumber = getLuggageByTrackingNumber;
const getUserLuggage = async (userId) => {
    return prisma_1.default.luggage.findMany({
        where: {
            booking: {
                userId,
            },
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
            trackingEvents: {
                orderBy: {
                    createdAt: "asc",
                },
            },
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getUserLuggage = getUserLuggage;
const updateLuggageStatus = async (data) => {
    return prisma_1.default.$transaction(async (tx) => {
        const luggage = await tx.luggage.findUnique({
            where: {
                id: data.luggageId,
            },
        });
        if (!luggage) {
            throw new Error("Luggage not found");
        }
        const currentStatus = luggage.status;
        const allowedStatuses = validLuggageTransitions[currentStatus];
        if (!allowedStatuses.includes(data.status)) {
            throw new Error(`Invalid luggage status transition: ${currentStatus} -> ${data.status}`);
        }
        const progressPercentage = luggageProgress[data.status];
        await tx.luggage.update({
            where: {
                id: data.luggageId,
            },
            data: {
                status: data.status,
                progressPercentage,
            },
        });
        await tx.luggageTrackingEvent.create({
            data: {
                status: data.status,
                progressPercentage,
                location: data.location,
                description: data.description,
                luggageId: data.luggageId,
                updatedById: data.updatedById,
            },
        });
        return tx.luggage.findUnique({
            where: {
                id: data.luggageId,
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
                trackingEvents: {
                    orderBy: {
                        createdAt: "asc",
                    },
                },
            },
        });
    });
};
exports.updateLuggageStatus = updateLuggageStatus;
const getAgencyStaffMembership = async (userId, agencyId) => {
    return prisma_1.default.agencyStaff.findFirst({
        where: {
            userId,
            agencyId,
            isActive: true,
        },
    });
};
exports.getAgencyStaffMembership = getAgencyStaffMembership;
//# sourceMappingURL=luggage.service.js.map