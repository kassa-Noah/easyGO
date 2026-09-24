import {
  Request,
  Response,
} from "express";

import {
  createReview,
  deleteReview,
  getAgencyForReview,
  getAgencyReviews,
  getCompletedBookingForReview,
  getExistingTripReview,
  getReviewById,
  getTripForReview,
  getUserReviews,
  updateReview,
} from "./review.service";

import {
  createReviewSchema,
  updateReviewSchema,
} from "./review.schema";

export const addReview = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData =
      createReviewSchema.parse(
        req.body
      );

    const agency =
      await getAgencyForReview(
        validatedData.agencyId
      );

    if (!agency) {
      return res.status(404).json({
        success: false,
        message:
          "Agency not found",
      });
    }

    if (!agency.isActive) {
      return res.status(400).json({
        success: false,
        message:
          "This agency is not active",
      });
    }

    const trip =
      await getTripForReview(
        validatedData.tripId
      );

    if (!trip) {
      return res.status(404).json({
        success: false,
        message:
          "Trip not found",
      });
    }

    if (
      trip.agencyId !==
      validatedData.agencyId
    ) {
      return res.status(400).json({
        success: false,
        message:
          "The selected trip does not belong to this agency",
      });
    }

    const completedBooking =
      await getCompletedBookingForReview(
        req.user!.userId,
        validatedData.tripId
      );

    if (!completedBooking) {
      return res.status(403).json({
        success: false,
        message:
          "You can only review a trip that you have completed",
      });
    }

    const existingReview =
      await getExistingTripReview(
        req.user!.userId,
        validatedData.tripId
      );

    if (existingReview) {
      return res.status(409).json({
        success: false,
        message:
          "You have already reviewed this trip",
      });
    }

    const review =
      await createReview({
        userId:
          req.user!.userId,

        ...validatedData,
      });

    return res.status(201).json({
      success: true,
      message:
        "Review created successfully",
      data: review,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to create review",
    });
  }
};

export const listAgencyReviews =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const agencyId = String(
        req.params.agencyId
      );

      const agency =
        await getAgencyForReview(
          agencyId
        );

      if (!agency) {
        return res.status(404).json({
          success: false,
          message:
            "Agency not found",
        });
      }

      const reviews =
        await getAgencyReviews(
          agencyId
        );

      const averageRating =
        reviews.length === 0
          ? 0
          : reviews.reduce(
              (
                total,
                review
              ) =>
                total +
                review.rating,
              0
            ) / reviews.length;

      return res.status(200).json({
        success: true,

        data: {
          count:
            reviews.length,

          averageRating:
            Number(
              averageRating.toFixed(
                2
              )
            ),

          reviews,
        },
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,
        message:
          error.message ||
          "Unable to retrieve agency reviews",
      });
    }
  };

export const listMyReviews = async (
  req: Request,
  res: Response
) => {
  try {
    const reviews =
      await getUserReviews(
        req.user!.userId
      );

    return res.status(200).json({
      success: true,
      count: reviews.length,
      data: reviews,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve reviews",
    });
  }
};

export const editReview = async (
  req: Request,
  res: Response
) => {
  try {
    const reviewId = String(
      req.params.id
    );

    const review =
      await getReviewById(
        reviewId
      );

    if (!review) {
      return res.status(404).json({
        success: false,
        message:
          "Review not found",
      });
    }

    if (
      review.userId !==
      req.user!.userId
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to update this review",
      });
    }

    const validatedData =
      updateReviewSchema.parse(
        req.body
      );

    const updatedReview =
      await updateReview(
        reviewId,
        validatedData
      );

    return res.status(200).json({
      success: true,
      message:
        "Review updated successfully",
      data: updatedReview,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to update review",
    });
  }
};

export const removeReview = async (
  req: Request,
  res: Response
) => {
  try {
    const reviewId = String(
      req.params.id
    );

    const review =
      await getReviewById(
        reviewId
      );

    if (!review) {
      return res.status(404).json({
        success: false,
        message:
          "Review not found",
      });
    }

    if (
      review.userId !==
      req.user!.userId
    ) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to delete this review",
      });
    }

    await deleteReview(
      reviewId
    );

    return res.status(200).json({
      success: true,
      message:
        "Review deleted successfully",
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to delete review",
    });
  }
};