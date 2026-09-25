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

// ======================================================
// SIMULATED TAXI PROVIDER
// ======================================================
//
// No production taxi partnership is available, so the prototype
// requests the first-mile and last-mile rides through a mock
// provider. The provider is stored with type SIMULATED and every
// assignment carries a SIM-... external reference, so the
// simulation is never mistaken for a real dispatch.
//
// Driver and vehicle data is derived from the journey id, which
// keeps a demonstration reproducible: the same journey always
// returns the same driver and vehicle.

type TaxiSegment =
  | "HOME_TO_DEPARTURE_AGENCY"
  | "ARRIVAL_AGENCY_TO_DESTINATION";

const SIMULATED_PROVIDER_NAME =
  "easyGO Simulated Taxi Service";

const SIMULATED_DRIVERS = [
  {
    name: "Ngassa Emmanuel",
    phone: "+237677001122",
  },
  {
    name: "Tchoumi Bertrand",
    phone: "+237699223344",
  },
  {
    name: "Awa Nkeng",
    phone: "+237655334455",
  },
  {
    name: "Mbarga Serge",
    phone: "+237690445566",
  },
];

const SIMULATED_VEHICLES = [
  {
    registration: "LT-TX-1042",
    description: "Yellow Toyota Corolla",
  },
  {
    registration: "LT-TX-2287",
    description: "Yellow Hyundai Accent",
  },
  {
    registration: "LT-TX-3391",
    description: "Yellow Kia Rio",
  },
  {
    registration: "LT-TX-4176",
    description: "Yellow Toyota Yaris",
  },
];

const SIMULATED_SEGMENT_FARE: Record<
  TaxiSegment,
  number
> = {
  HOME_TO_DEPARTURE_AGENCY: 2500,
  ARRIVAL_AGENCY_TO_DESTINATION: 3000,
};

const hashString = (value: string) => {
  let hash = 0;

  for (
    let index = 0;
    index < value.length;
    index += 1
  ) {
    hash =
      (hash * 31 +
        value.charCodeAt(index)) >>>
      0;
  }

  return hash;
};

export const ensureSimulatedTaxiProvider =
  async () => {
    const existing =
      await prisma.taxiProvider.findFirst({
        where: {
          name: SIMULATED_PROVIDER_NAME,
        },
      });

    if (existing) {
      return existing;
    }

    return prisma.taxiProvider.create({
      data: {
        name: SIMULATED_PROVIDER_NAME,
        type: "SIMULATED",
        isActive: true,
      },
    });
  };

// Creates the simulated ride for one segment. Repeated calls for the
// same journey and segment return the existing assignment, so a
// retried request never produces a second driver.
export const assignSimulatedTaxiSegment =
  async (
    journeyId: string,
    segmentType: TaxiSegment
  ) => {
    const existing =
      await prisma.taxiAssignment.findFirst({
        where: {
          journeyId,
          segmentType,
        },
      });

    if (existing) {
      return existing;
    }

    const journey =
      await prisma.doorToDoorJourney.findUnique({
        where: {
          id: journeyId,
        },

        include: {
          booking: {
            include: {
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
          },
        },
      });

    if (!journey) {
      throw new Error("Journey not found");
    }

    const route =
      journey.booking.trip.route;

    const isFirstMile =
      segmentType ===
      "HOME_TO_DEPARTURE_AGENCY";

    // The first mile runs from the traveller's address to the
    // departure agency; the last mile runs from the arrival agency
    // to the traveller's final destination.
    const agencyBranch = isFirstMile
      ? route.originBranch
      : route.destinationBranch;

    const pickupAddress = isFirstMile
      ? journey.pickupAddress
      : agencyBranch.address;

    const dropoffAddress = isFirstMile
      ? agencyBranch.address
      : journey.destinationAddress;

    const provider =
      await ensureSimulatedTaxiProvider();

    const seed = hashString(
      `${journeyId}:${segmentType}`
    );

    const driver =
      SIMULATED_DRIVERS[
        seed % SIMULATED_DRIVERS.length
      ];

    const vehicle =
      SIMULATED_VEHICLES[
        (seed >>> 3) %
          SIMULATED_VEHICLES.length
      ];

    const externalReference = `SIM-${
      isFirstMile ? "PICKUP" : "DROPOFF"
    }-${journeyId
      .replace(/-/g, "")
      .slice(0, 8)
      .toUpperCase()}`;

    return prisma.taxiAssignment.create({
      data: {
        segmentType,
        status: "DRIVER_ASSIGNED",

        driverName: driver.name,
        driverPhone: driver.phone,

        vehicleRegistration:
          vehicle.registration,
        vehicleDescription:
          vehicle.description,

        externalReference,

        pickupAddress,
        dropoffAddress,

        estimatedFare:
          SIMULATED_SEGMENT_FARE[segmentType],

        assignedAt: new Date(),

        journeyId,
        providerId: provider.id,
      },

      include: {
        provider: true,
      },
    });
  };

// Requests the first-mile ride for a confirmed door-to-door booking
// and moves the journey to PICKUP_ASSIGNED. Returns null when the
// booking is not a door-to-door journey.
export const requestFirstMileTaxiAssignment =
  async (bookingId: string) => {
    const journey =
      await prisma.doorToDoorJourney.findUnique({
        where: {
          bookingId,
        },
      });

    if (!journey) {
      return null;
    }

    const assignment =
      await assignSimulatedTaxiSegment(
        journey.id,
        "HOME_TO_DEPARTURE_AGENCY"
      );

    if (
      journey.status === "PENDING" ||
      journey.status === "CONFIRMED"
    ) {
      await prisma.doorToDoorJourney.update({
        where: {
          id: journey.id,
        },

        data: {
          status: "PICKUP_ASSIGNED",
        },
      });
    }

    return assignment;
  };

// Requests the last-mile ride once the traveller reaches the arrival
// agency. The journey only moves to DROPOFF_ASSIGNED when it is still
// at an earlier stage, so a repeated request can never move a journey
// that has already progressed backwards.
const PRE_DROPOFF_STATUSES = [
  "PENDING",
  "CONFIRMED",
  "PICKUP_ASSIGNED",
  "PICKUP_IN_PROGRESS",
  "AT_DEPARTURE_AGENCY",
  "INTERURBAN_IN_PROGRESS",
  "AT_ARRIVAL_AGENCY",
];

export const requestLastMileTaxiAssignment =
  async (journeyId: string) => {
    const assignment =
      await assignSimulatedTaxiSegment(
        journeyId,
        "ARRIVAL_AGENCY_TO_DESTINATION"
      );

    const journey =
      await prisma.doorToDoorJourney.findUnique({
        where: {
          id: journeyId,
        },
      });

    if (
      journey &&
      PRE_DROPOFF_STATUSES.includes(
        journey.status
      )
    ) {
      await prisma.doorToDoorJourney.update({
        where: {
          id: journeyId,
        },

        data: {
          status: "DROPOFF_ASSIGNED",
        },
      });
    }

    return assignment;
  };