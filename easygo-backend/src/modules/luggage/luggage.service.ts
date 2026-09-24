import prisma from "../../lib/prisma";

interface CreateLuggageInput {
  bookingId: string;
  description?: string;
  weightKg?: number;
}

type LuggageStatus =
  | "REGISTERED"
  | "RECEIVED_AT_AGENCY"
  | "LOADED"
  | "IN_TRANSIT"
  | "ARRIVED_AT_DESTINATION_AGENCY"
  | "READY_FOR_COLLECTION"
  | "DELIVERED"
  | "LOST";

interface UpdateLuggageStatusInput {
  luggageId: string;
  status: LuggageStatus;
  location?: string;
  description?: string;
  updatedById: string;
}

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

const luggageProgress: Record<
  LuggageStatus,
  number
> = {
  REGISTERED: 0,
  RECEIVED_AT_AGENCY: 15,
  LOADED: 30,
  IN_TRANSIT: 55,
  ARRIVED_AT_DESTINATION_AGENCY: 75,
  READY_FOR_COLLECTION: 90,
  DELIVERED: 100,
  LOST: 0,
};

const validLuggageTransitions: Record<
  LuggageStatus,
  LuggageStatus[]
> = {
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

export const getBookingForLuggage = async (
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

      luggage: true,
    },
  });
};

export const createLuggage = async (
  data: CreateLuggageInput
) => {
  return prisma.$transaction(
    async (tx) => {
      const trackingNumber =
        generateTrackingNumber();

      const luggage =
        await tx.luggage.create({
          data: {
            trackingNumber,

            description:
              data.description,

            weightKg:
              data.weightKg,

            status: "REGISTERED",

            progressPercentage: 0,

            bookingId:
              data.bookingId,
          },
        });

      await tx.luggageTrackingEvent.create({
        data: {
          status: "REGISTERED",

          progressPercentage: 0,

          description:
            "Luggage registered",

          luggageId:
            luggage.id,
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
    }
  );
};

export const getLuggageById = async (
  luggageId: string
) => {
  return prisma.luggage.findUnique({
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

export const getLuggageByTrackingNumber =
  async (
    trackingNumber: string
  ) => {
    return prisma.luggage.findUnique({
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

export const getUserLuggage = async (
  userId: string
) => {
  return prisma.luggage.findMany({
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

export const updateLuggageStatus =
  async (
    data: UpdateLuggageStatusInput
  ) => {
    return prisma.$transaction(
      async (tx) => {
        const luggage =
          await tx.luggage.findUnique({
            where: {
              id: data.luggageId,
            },
          });

        if (!luggage) {
          throw new Error(
            "Luggage not found"
          );
        }

        const currentStatus =
          luggage.status as LuggageStatus;

        const allowedStatuses =
          validLuggageTransitions[
            currentStatus
          ];

        if (
          !allowedStatuses.includes(
            data.status
          )
        ) {
          throw new Error(
            `Invalid luggage status transition: ${currentStatus} -> ${data.status}`
          );
        }

        const progressPercentage =
          luggageProgress[data.status];

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

            location:
              data.location,

            description:
              data.description,

            luggageId:
              data.luggageId,

            updatedById:
              data.updatedById,
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
      }
    );
  };

export const getAgencyStaffMembership =
  async (
    userId: string,
    agencyId: string
  ) => {
    return prisma.agencyStaff.findFirst({
      where: {
        userId,
        agencyId,
        isActive: true,
      },
    });
  };