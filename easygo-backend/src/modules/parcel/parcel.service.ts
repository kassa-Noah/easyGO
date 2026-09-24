import prisma from "../../lib/prisma";

interface CreateParcelInput {
  senderId: string;
  description: string;
  weightKg?: number;
  recipientName: string;
  recipientPhone: string;
  recipientUserId?: string;
  originBranchId: string;
  destinationBranchId: string;
  tripId?: string;
}

type ParcelStatus =
  | "REGISTERED"
  | "RECEIVED_AT_ORIGIN_AGENCY"
  | "LOADED"
  | "IN_TRANSIT"
  | "ARRIVED_AT_DESTINATION_AGENCY"
  | "READY_FOR_COLLECTION"
  | "COLLECTED"
  | "DELIVERED"
  | "LOST"
  | "CANCELLED";

interface UpdateParcelStatusInput {
  parcelId: string;
  status: ParcelStatus;
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

  return `PAR-${timestamp}-${randomPart}`;
};

const parcelProgress: Record<
  ParcelStatus,
  number
> = {
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

const validParcelTransitions: Record<
  ParcelStatus,
  ParcelStatus[]
> = {
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

export const getBranchById = async (
  branchId: string
) => {
  return prisma.agencyBranch.findUnique({
    where: {
      id: branchId,
    },

    include: {
      agency: true,
    },
  });
};

export const getTripForParcel = async (
  tripId: string
) => {
  return prisma.trip.findUnique({
    where: {
      id: tripId,
    },

    include: {
      agency: true,
      route: true,
    },
  });
};

export const getRecipientUser = async (
  userId: string
) => {
  return prisma.user.findUnique({
    where: {
      id: userId,
    },
  });
};

export const createParcel = async (
  data: CreateParcelInput
) => {
  return prisma.$transaction(
    async (tx) => {
      const trackingNumber =
        generateTrackingNumber();

      const parcel =
        await tx.parcel.create({
          data: {
            trackingNumber,

            description:
              data.description,

            weightKg:
              data.weightKg,

            recipientName:
              data.recipientName,

            recipientPhone:
              data.recipientPhone,

            status:
              "REGISTERED",

            progressPercentage: 0,

            senderId:
              data.senderId,

            recipientUserId:
              data.recipientUserId,

            originBranchId:
              data.originBranchId,

            destinationBranchId:
              data.destinationBranchId,

            tripId:
              data.tripId,
          },
        });

      await tx.parcelTrackingEvent.create({
        data: {
          status:
            "REGISTERED",

          progressPercentage: 0,

          description:
            "Parcel registered",

          parcelId:
            parcel.id,

          updatedById:
            data.senderId,
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
    }
  );
};

export const getParcelById = async (
  parcelId: string
) => {
  return prisma.parcel.findUnique({
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

export const getParcelByTrackingNumber =
  async (
    trackingNumber: string
  ) => {
    return prisma.parcel.findUnique({
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

export const getUserParcels = async (
  userId: string
) => {
  return prisma.parcel.findMany({
    where: {
      OR: [
        {
          senderId:
            userId,
        },

        {
          recipientUserId:
            userId,
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

export const updateParcelStatus =
  async (
    data: UpdateParcelStatusInput
  ) => {
    return prisma.$transaction(
      async (tx) => {
        const parcel =
          await tx.parcel.findUnique({
            where: {
              id: data.parcelId,
            },
          });

        if (!parcel) {
          throw new Error(
            "Parcel not found"
          );
        }

        const currentStatus =
          parcel.status as ParcelStatus;

        const allowedStatuses =
          validParcelTransitions[
            currentStatus
          ];

        if (
          !allowedStatuses.includes(
            data.status
          )
        ) {
          throw new Error(
            `Invalid parcel status transition: ${currentStatus} -> ${data.status}`
          );
        }

        const progressPercentage =
          parcelProgress[
            data.status
          ];

        await tx.parcel.update({
          where: {
            id: data.parcelId,
          },

          data: {
            status:
              data.status,

            progressPercentage,
          },
        });

        await tx.parcelTrackingEvent.create({
          data: {
            status:
              data.status,

            progressPercentage,

            location:
              data.location,

            description:
              data.description,

            parcelId:
              data.parcelId,

            updatedById:
              data.updatedById,
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