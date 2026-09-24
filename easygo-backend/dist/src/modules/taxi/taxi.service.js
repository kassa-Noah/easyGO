"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAgencyStaffMembership = exports.updateTaxiAssignment = exports.getJourneyTaxiAssignments = exports.getTaxiAssignmentById = exports.createTaxiAssignment = exports.getExistingTaxiAssignment = exports.getJourneyForTaxiAssignment = exports.getTaxiProviderById = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getTaxiProviderById = async (providerId) => {
    return prisma_1.default.taxiProvider.findUnique({
        where: {
            id: providerId,
        },
    });
};
exports.getTaxiProviderById = getTaxiProviderById;
const getJourneyForTaxiAssignment = async (journeyId) => {
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
exports.getJourneyForTaxiAssignment = getJourneyForTaxiAssignment;
const getExistingTaxiAssignment = async (journeyId, segmentType) => {
    return prisma_1.default.taxiAssignment.findFirst({
        where: {
            journeyId,
            segmentType,
        },
    });
};
exports.getExistingTaxiAssignment = getExistingTaxiAssignment;
const createTaxiAssignment = async (data) => {
    return prisma_1.default.taxiAssignment.create({
        data: {
            journeyId: data.journeyId,
            providerId: data.providerId,
            segmentType: data.segmentType,
            pickupAddress: data.pickupAddress,
            dropoffAddress: data.dropoffAddress,
            estimatedFare: data.estimatedFare,
        },
        include: {
            provider: true,
            journey: {
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
                },
            },
        },
    });
};
exports.createTaxiAssignment = createTaxiAssignment;
const getTaxiAssignmentById = async (assignmentId) => {
    return prisma_1.default.taxiAssignment.findUnique({
        where: {
            id: assignmentId,
        },
        include: {
            provider: true,
            journey: {
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
                },
            },
        },
    });
};
exports.getTaxiAssignmentById = getTaxiAssignmentById;
const getJourneyTaxiAssignments = async (journeyId) => {
    return prisma_1.default.taxiAssignment.findMany({
        where: {
            journeyId,
        },
        include: {
            provider: true,
        },
        orderBy: {
            createdAt: "asc",
        },
    });
};
exports.getJourneyTaxiAssignments = getJourneyTaxiAssignments;
const updateTaxiAssignment = async (assignmentId, data) => {
    const updateData = {
        ...data,
    };
    if (data.status === "DRIVER_ASSIGNED") {
        updateData.assignedAt = new Date();
    }
    if (data.status === "COMPLETED") {
        updateData.completedAt = new Date();
    }
    return prisma_1.default.taxiAssignment.update({
        where: {
            id: assignmentId,
        },
        data: updateData,
        include: {
            provider: true,
            journey: {
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
                },
            },
        },
    });
};
exports.updateTaxiAssignment = updateTaxiAssignment;
const getAgencyStaffMembership = async (userId, agencyId) => {
    return prisma_1.default.agencyStaff.findFirst({
        where: {
            userId,
            agencyId,
        },
    });
};
exports.getAgencyStaffMembership = getAgencyStaffMembership;
//# sourceMappingURL=taxi.service.js.map