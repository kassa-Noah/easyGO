"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.removeReview = exports.editReview = exports.listMyReviews = exports.listAgencyReviews = exports.addReview = void 0;
const review_service_1 = require("./review.service");
const review_schema_1 = require("./review.schema");
const addReview = async (req, res) => {
    try {
        const validatedData = review_schema_1.createReviewSchema.parse(req.body);
        const agency = await (0, review_service_1.getAgencyForReview)(validatedData.agencyId);
        if (!agency) {
            return res.status(404).json({
                success: false,
                message: "Agency not found",
            });
        }
        if (!agency.isActive) {
            return res.status(400).json({
                success: false,
                message: "This agency is not active",
            });
        }
        const trip = await (0, review_service_1.getTripForReview)(validatedData.tripId);
        if (!trip) {
            return res.status(404).json({
                success: false,
                message: "Trip not found",
            });
        }
        if (trip.agencyId !==
            validatedData.agencyId) {
            return res.status(400).json({
                success: false,
                message: "The selected trip does not belong to this agency",
            });
        }
        const completedBooking = await (0, review_service_1.getCompletedBookingForReview)(req.user.userId, validatedData.tripId);
        if (!completedBooking) {
            return res.status(403).json({
                success: false,
                message: "You can only review a trip that you have completed",
            });
        }
        const existingReview = await (0, review_service_1.getExistingTripReview)(req.user.userId, validatedData.tripId);
        if (existingReview) {
            return res.status(409).json({
                success: false,
                message: "You have already reviewed this trip",
            });
        }
        const review = await (0, review_service_1.createReview)({
            userId: req.user.userId,
            ...validatedData,
        });
        return res.status(201).json({
            success: true,
            message: "Review created successfully",
            data: review,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to create review",
        });
    }
};
exports.addReview = addReview;
const listAgencyReviews = async (req, res) => {
    try {
        const agencyId = String(req.params.agencyId);
        const agency = await (0, review_service_1.getAgencyForReview)(agencyId);
        if (!agency) {
            return res.status(404).json({
                success: false,
                message: "Agency not found",
            });
        }
        const reviews = await (0, review_service_1.getAgencyReviews)(agencyId);
        const averageRating = reviews.length === 0
            ? 0
            : reviews.reduce((total, review) => total +
                review.rating, 0) / reviews.length;
        return res.status(200).json({
            success: true,
            data: {
                count: reviews.length,
                averageRating: Number(averageRating.toFixed(2)),
                reviews,
            },
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve agency reviews",
        });
    }
};
exports.listAgencyReviews = listAgencyReviews;
const listMyReviews = async (req, res) => {
    try {
        const reviews = await (0, review_service_1.getUserReviews)(req.user.userId);
        return res.status(200).json({
            success: true,
            count: reviews.length,
            data: reviews,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve reviews",
        });
    }
};
exports.listMyReviews = listMyReviews;
const editReview = async (req, res) => {
    try {
        const reviewId = String(req.params.id);
        const review = await (0, review_service_1.getReviewById)(reviewId);
        if (!review) {
            return res.status(404).json({
                success: false,
                message: "Review not found",
            });
        }
        if (review.userId !==
            req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to update this review",
            });
        }
        const validatedData = review_schema_1.updateReviewSchema.parse(req.body);
        const updatedReview = await (0, review_service_1.updateReview)(reviewId, validatedData);
        return res.status(200).json({
            success: true,
            message: "Review updated successfully",
            data: updatedReview,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to update review",
        });
    }
};
exports.editReview = editReview;
const removeReview = async (req, res) => {
    try {
        const reviewId = String(req.params.id);
        const review = await (0, review_service_1.getReviewById)(reviewId);
        if (!review) {
            return res.status(404).json({
                success: false,
                message: "Review not found",
            });
        }
        if (review.userId !==
            req.user.userId) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to delete this review",
            });
        }
        await (0, review_service_1.deleteReview)(reviewId);
        return res.status(200).json({
            success: true,
            message: "Review deleted successfully",
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to delete review",
        });
    }
};
exports.removeReview = removeReview;
//# sourceMappingURL=review.controller.js.map