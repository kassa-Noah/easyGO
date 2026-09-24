import prisma from "../../lib/prisma";

interface CreateJourneyInput {
  bookingId: string;
  pickupAddress: string;
  pickupLatitude?: number;
  pickupLongitude?: number;
  destinationAddress: string;
  destinationLatitude?: number;
  destinationLongitude?: number;
}

export const getBookingForJourney = async (
  bookingId: string
) => {
  return prisma.booking.findUnique({
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

export const createJourney = async (
  userId: string,
  data: CreateJourneyInput
) => {
  return prisma.doorToDoorJourney.create({
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

export const getJourneyById = async (
  journeyId: string
) => {
  return prisma.doorToDoorJourney.findUnique({
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

export const getUserJourneys = async (
  userId: string
) => {
  return prisma.doorToDoorJourney.findMany({
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

export const updateJourneyStatus = async (
  journeyId: string,
  status:
    | "PENDING"
    | "CONFIRMED"
    | "PICKUP_ASSIGNED"
    | "PICKUP_IN_PROGRESS"
    | "AT_DEPARTURE_AGENCY"
    | "INTERURBAN_IN_PROGRESS"
    | "AT_ARRIVAL_AGENCY"
    | "DROPOFF_ASSIGNED"
    | "DROPOFF_IN_PROGRESS"
    | "COMPLETED"
    | "CANCELLED"
) => {
  return prisma.doorToDoorJourney.update({
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