"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteReview = exports.updateReview = exports.getUserReviews = exports.getAgencyReviews = exports.getReviewById = exports.createReview = exports.getExistingTripReview = exports.getCompletedBookingForReview = exports.getTripForReview = exports.getAgencyForReview = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getAgencyForReview = async (agencyId) => {
    return prisma_1.default.agency.findUnique({
        where: {
            id: agencyId,
        },
    });
};
exports.getAgencyForReview = getAgencyForReview;
const getTripForReview = async (tripId) => {
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
        },
    });
};
exports.getTripForReview = getTripForReview;
const getCompletedBookingForReview = async (userId, tripId) => {
    return prisma_1.default.booking.findFirst({
        where: {
            userId,
            tripId,
            status: "COMPLETED",
        },
    });
};
exports.getCompletedBookingForReview = getCompletedBookingForReview;
const getExistingTripReview = async (userId, tripId) => {
    return prisma_1.default.review.findFirst({
        where: {
            userId,
            tripId,
        },
    });
};
exports.getExistingTripReview = getExistingTripReview;
const createReview = async (data) => {
    return prisma_1.default.review.create({
        data: {
            userId: data.userId,
            agencyId: data.agencyId,
            tripId: data.tripId,
            rating: data.rating,
            comment: data.comment,
        },
        include: {
            user: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                },
            },
            agency: true,
            trip: {
                include: {
                    route: {
                        include: {
                            originBranch: true,
                            destinationBranch: true,
                        },
                    },
                },
            },
        },
    });
};
exports.createReview = createReview;
const getReviewById = async (reviewId) => {
    return prisma_1.default.review.findUnique({
        where: {
            id: reviewId,
        },
        include: {
            user: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                },
            },
            agency: true,
            trip: {
                include: {
                    route: {
                        include: {
                            originBranch: true,
                            destinationBranch: true,
                        },
                    },
                },
            },
        },
    });
};
exports.getReviewById = getReviewById;
const getAgencyReviews = async (agencyId) => {
    return prisma_1.default.review.findMany({
        where: {
            agencyId,
        },
        include: {
            user: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                },
            },
            trip: {
                include: {
                    route: {
                        include: {
                            originBranch: true,
                            destinationBranch: true,
                        },
                    },
                },
            },
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getAgencyReviews = getAgencyReviews;
const getUserReviews = async (userId) => {
    return prisma_1.default.review.findMany({
        where: {
            userId,
        },
        include: {
            agency: true,
            trip: true,
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getUserReviews = getUserReviews;
const updateReview = async (reviewId, data) => {
    return prisma_1.default.review.update({
        where: {
            id: reviewId,
        },
        data: {
            ...(data.rating !== undefined
                ? {
                    rating: data.rating,
                }
                : {}),
            ...(data.comment !== undefined
                ? {
                    comment: data.comment,
                }
                : {}),
        },
        include: {
            agency: true,
            trip: true,
        },
    });
};
exports.updateReview = updateReview;
const deleteReview = async (reviewId) => {
    return prisma_1.default.review.delete({
        where: {
            id: reviewId,
        },
    });
};
exports.deleteReview = deleteReview;
//# sourceMappingURL=review.service.js.map