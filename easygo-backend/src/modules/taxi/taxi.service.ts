import prisma from "../../lib/prisma";

interface CreateTaxiAssignmentInput {
  journeyId: string;

  providerId: string;

  segmentType:
    | "HOME_TO_DEPARTURE_AGENCY"
    | "ARRIVAL_AGENCY_TO_DESTINATION";

  pickupAddress: string;
  dropoffAddress: string;

  estimatedFare?: number;
}

interface UpdateTaxiAssignmentInput {
  status?:
    | "PENDING"
    | "DRIVER_ASSIGNED"
    | "DRIVER_ARRIVING"
    | "PASSENGER_PICKED_UP"
    | "COMPLETED"
    | "CANCELLED";

  driverName?: string;
  driverPhone?: string;

  vehicleRegistration?: string;
  vehicleDescription?: string;

  externalReference?: string;

  finalFare?: number;
}

export const getTaxiProviderById = async (
  providerId: string
) => {
  return prisma.taxiProvider.findUnique({
    where: {
      id: providerId,
    },
  });
};

export const getJourneyForTaxiAssignment =
  async (journeyId: string) => {
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

export const getExistingTaxiAssignment =
  async (
    journeyId: string,
    segmentType:
      | "HOME_TO_DEPARTURE_AGENCY"
      | "ARRIVAL_AGENCY_TO_DESTINATION"
  ) => {
    return prisma.taxiAssignment.findFirst({
      where: {
        journeyId,
        segmentType,
      },
    });
  };

export const createTaxiAssignment = async (
  data: CreateTaxiAssignmentInput
) => {
  return prisma.taxiAssignment.create({
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

export const getTaxiAssignmentById =
  async (assignmentId: string) => {
    return prisma.taxiAssignment.findUnique({
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

export const getJourneyTaxiAssignments =
  async (journeyId: string) => {
    return prisma.taxiAssignment.findMany({
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

export const updateTaxiAssignment =
  async (
    assignmentId: string,
    data: UpdateTaxiAssignmentInput
  ) => {
    const updateData: any = {
      ...data,
    };

    if (
      data.status === "DRIVER_ASSIGNED"
    ) {
      updateData.assignedAt = new Date();
    }

    if (data.status === "COMPLETED") {
      updateData.completedAt = new Date();
    }

    return prisma.taxiAssignment.update({
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

export const getAgencyStaffMembership =
  async (
    userId: string,
    agencyId: string
  ) => {
    return prisma.agencyStaff.findFirst({
      where: {
        userId,
        agencyId,
      },
    });
  };