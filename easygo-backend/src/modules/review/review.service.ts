import prisma from "../../lib/prisma";

interface CreateReviewInput {
  userId: string;
  agencyId: string;
  tripId: string;
  rating: number;
  comment?: string;
}

interface UpdateReviewInput {
  rating?: number;
  comment?: string;
}

export const getAgencyForReview = async (
  agencyId: string
) => {
  return prisma.agency.findUnique({
    where: {
      id: agencyId,
    },
  });
};

export const getTripForReview = async (
  tripId: string
) => {
  return prisma.trip.findUnique({
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

export const getCompletedBookingForReview =
  async (
    userId: string,
    tripId: string
  ) => {
    return prisma.booking.findFirst({
      where: {
        userId,
        tripId,
        status: "COMPLETED",
      },
    });
  };

export const getExistingTripReview = async (
  userId: string,
  tripId: string
) => {
  return prisma.review.findFirst({
    where: {
      userId,
      tripId,
    },
  });
};

export const createReview = async (
  data: CreateReviewInput
) => {
  return prisma.review.create({
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

export const getReviewById = async (
  reviewId: string
) => {
  return prisma.review.findUnique({
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

export const getAgencyReviews = async (
  agencyId: string
) => {
  return prisma.review.findMany({
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

export const getUserReviews = async (
  userId: string
) => {
  return prisma.review.findMany({
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

export const updateReview = async (
  reviewId: string,
  data: UpdateReviewInput
) => {
  return prisma.review.update({
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

export const deleteReview = async (
  reviewId: string
) => {
  return prisma.review.delete({
    where: {
      id: reviewId,
    },
  });
};