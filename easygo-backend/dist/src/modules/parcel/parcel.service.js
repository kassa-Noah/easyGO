"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAgencyStaffMembership = exports.updateParcelStatus = exports.getUserParcels = exports.getParcelByTrackingNumber = exports.getParcelById = exports.createParcel = exports.getRecipientUser = exports.getTripForParcel = exports.getBranchById = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const generateTrackingNumber = () => {
    const timestamp = Date.now()
        .toString(36)
        .toUpperCase();
    const randomPart = Math.random()
        .toString(36)
        .substring(2, 8)
        .toUpperCase();
    return `PAR-${timestamp}-${randomPart}`;
};
const parcelProgress = {
    REGISTERED: 0,
    RECEIVED_AT_ORIGIN_AGENCY: 15,
    LOADED: 30,
    IN_TRANSIT: 55,
    ARRIVED_AT_DESTINATION_AGENCY: 75,
    READY_FOR_COLLECTION: 90,
    COLLECTED: 100,
    DELIVERED: 100,
    LOST: 0,
    CANCELLED: 0,
};
const validParcelTransitions = {
    REGISTERED: [
        "RECEIVED_AT_ORIGIN_AGENCY",
        "CANCELLED",
    ],
    RECEIVED_AT_ORIGIN_AGENCY: [
        "LOADED",
        "LOST",
        "CANCELLED",
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
        "COLLECTED",
        "DELIVERED",
        "LOST",
    ],
    COLLECTED: [],
    DELIVERED: [],
    LOST: [],
    CANCELLED: [],
};
const getBranchById = async (branchId) => {
    return prisma_1.default.agencyBranch.findUnique({
        where: {
            id: branchId,
        },
        include: {
            agency: true,
        },
    });
};
exports.getBranchById = getBranchById;
const getTripForParcel = async (tripId) => {
    return prisma_1.default.trip.findUnique({
        where: {
            id: tripId,
        },
        include: {
            agency: true,
            route: true,
        },
    });
};
exports.getTripForParcel = getTripForParcel;
const getRecipientUser = async (userId) => {
    return prisma_1.default.user.findUnique({
        where: {
            id: userId,
        },
    });
};
exports.getRecipientUser = getRecipientUser;
const createParcel = async (data) => {
    return prisma_1.default.$transaction(async (tx) => {
        const trackingNumber = generateTrackingNumber();
        const parcel = await tx.parcel.create({
            data: {
                trackingNumber,
                description: data.description,
                weightKg: data.weightKg,
                recipientName: data.recipientName,
                recipientPhone: data.recipientPhone,
                status: "REGISTERED",
                progressPercentage: 0,
                senderId: data.senderId,
                recipientUserId: data.recipientUserId,
                originBranchId: data.originBranchId,
                destinationBranchId: data.destinationBranchId,
                tripId: data.tripId,
            },
        });
        await tx.parcelTrackingEvent.create({
            data: {
                status: "REGISTERED",
                progressPercentage: 0,
                description: "Parcel registered",
                parcelId: parcel.id,
                updatedById: data.senderId,
            },
        });
        return tx.parcel.findUnique({
            where: {
                id: parcel.id,
            },
            include: {
                sender: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                        phone: true,
                    },
                },
                recipientUser: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                        phone: true,
                    },
                },
                originBranch: {
                    include: {
                        agency: true,
                    },
                },
                destinationBranch: {
                    include: {
                        agency: true,
                    },
                },
                trip: true,
                trackingEvents: {
                    orderBy: {
                        createdAt: "asc",
                    },
                },
            },
        });
    });
};
exports.createParcel = createParcel;
const getParcelById = async (parcelId) => {
    return prisma_1.default.parcel.findUnique({
        where: {
            id: parcelId,
        },
        include: {
            sender: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    email: true,
                    phone: true,
                },
            },
            recipientUser: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    email: true,
                    phone: true,
                },
            },
            originBranch: {
                include: {
                    agency: true,
                },
            },
            destinationBranch: {
                include: {
                    agency: true,
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
            trackingEvents: {
                orderBy: {
                    createdAt: "asc",
                },
            },
        },
    });
};
exports.getParcelById = getParcelById;
const getParcelByTrackingNumber = async (trackingNumber) => {
    return prisma_1.default.parcel.findUnique({
        where: {
            trackingNumber,
        },
        include: {
            sender: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                },
            },
            recipientUser: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                },
            },
            originBranch: {
                include: {
                    agency: true,
                },
            },
            destinationBranch: {
                include: {
                    agency: true,
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
            trackingEvents: {
                orderBy: {
                    createdAt: "asc",
                },
            },
        },
    });
};
exports.getParcelByTrackingNumber = getParcelByTrackingNumber;
const getUserParcels = async (userId) => {
    return prisma_1.default.parcel.findMany({
        where: {
            OR: [
                {
                    senderId: userId,
                },
                {
                    recipientUserId: userId,
                },
            ],
        },
        include: {
            sender: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                },
            },
            recipientUser: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                },
            },
            originBranch: {
                include: {
                    agency: true,
                },
            },
            destinationBranch: {
                include: {
                    agency: true,
                },
            },
            trip: true,
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
exports.getUserParcels = getUserParcels;
const updateParcelStatus = async (data) => {
    return prisma_1.default.$transaction(async (tx) => {
        const parcel = await tx.parcel.findUnique({
            where: {
                id: data.parcelId,
            },
        });
        if (!parcel) {
            throw new Error("Parcel not found");
        }
        const currentStatus = parcel.status;
        const allowedStatuses = validParcelTransitions[currentStatus];
        if (!allowedStatuses.includes(data.status)) {
            throw new Error(`Invalid parcel status transition: ${currentStatus} -> ${data.status}`);
        }
        const progressPercentage = parcelProgress[data.status];
        await tx.parcel.update({
            where: {
                id: data.parcelId,
            },
            data: {
                status: data.status,
                progressPercentage,
            },
        });
        await tx.parcelTrackingEvent.create({
            data: {
                status: data.status,
                progressPercentage,
                location: data.location,
                description: data.description,
                parcelId: data.parcelId,
                updatedById: data.updatedById,
            },
        });
        return tx.parcel.findUnique({
            where: {
                id: data.parcelId,
            },
            include: {
                sender: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                        phone: true,
                    },
                },
                recipientUser: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                        phone: true,
                    },
                },
                originBranch: {
                    include: {
                        agency: true,
                    },
                },
                destinationBranch: {
                    include: {
                        agency: true,
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
                trackingEvents: {
                    orderBy: {
                        createdAt: "asc",
                    },
                },
            },
        });
    });
};
exports.updateParcelStatus = updateParcelStatus;
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
//# sourceMappingURL=parcel.service.js.map