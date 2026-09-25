import prisma from "../../lib/prisma";

// ======================================================
// AGENCY CONSOLE
// ======================================================
//
// Every query here is scoped to the agency the signed-in staff
// member belongs to, so an agency can only ever read its own
// operational records. The agency is resolved from the staff
// membership rather than from a value supplied by the client.

export const getStaffMembership = async (
  userId: string
) => {
  return prisma.agencyStaff.findFirst({
    where: {
      userId,
      isActive: true,
    },

    include: {
      agency: {
        include: {
          branches: {
            orderBy: {
              city: "asc",
            },
          },
        },
      },
    },
  });
};

const bookingInclude = {
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

      vehicle: true,
    },
  },

  payments: true,
  ticket: true,
  journey: true,
  luggage: true,
};

export const getAgencyDashboard = async (
  agencyId: string
) => {
  const [
    totalTrips,
    scheduledTrips,
    departedTrips,
    arrivedTrips,
    cancelledTrips,

    totalBookings,
    pendingBookings,
    confirmedBookings,
    completedBookings,
    cancelledBookings,

    totalLuggage,
    inTransitLuggage,
    deliveredLuggage,

    totalParcels,
    inTransitParcels,
    deliveredParcels,

    revenueAggregate,
  ] = await Promise.all([
    prisma.trip.count({ where: { agencyId } }),

    prisma.trip.count({
      where: { agencyId, status: "SCHEDULED" },
    }),

    prisma.trip.count({
      where: { agencyId, status: "DEPARTED" },
    }),

    prisma.trip.count({
      where: { agencyId, status: "ARRIVED" },
    }),

    prisma.trip.count({
      where: { agencyId, status: "CANCELLED" },
    }),

    prisma.booking.count({
      where: { trip: { agencyId } },
    }),

    prisma.booking.count({
      where: { trip: { agencyId }, status: "PENDING" },
    }),

    prisma.booking.count({
      where: { trip: { agencyId }, status: "CONFIRMED" },
    }),

    prisma.booking.count({
      where: { trip: { agencyId }, status: "COMPLETED" },
    }),

    prisma.booking.count({
      where: { trip: { agencyId }, status: "CANCELLED" },
    }),

    prisma.luggage.count({
      where: { booking: { trip: { agencyId } } },
    }),

    prisma.luggage.count({
      where: {
        booking: { trip: { agencyId } },
        status: "IN_TRANSIT",
      },
    }),

    prisma.luggage.count({
      where: {
        booking: { trip: { agencyId } },
        status: "DELIVERED",
      },
    }),

    prisma.parcel.count({
      where: {
        OR: [
          { originBranch: { agencyId } },
          { destinationBranch: { agencyId } },
        ],
      },
    }),

    prisma.parcel.count({
      where: {
        OR: [
          { originBranch: { agencyId } },
          { destinationBranch: { agencyId } },
        ],
        status: "IN_TRANSIT",
      },
    }),

    prisma.parcel.count({
      where: {
        OR: [
          { originBranch: { agencyId } },
          { destinationBranch: { agencyId } },
        ],
        status: "DELIVERED",
      },
    }),

    prisma.payment.aggregate({
      where: {
        booking: { trip: { agencyId } },
        status: "SUCCESSFUL",
      },

      _sum: {
        amount: true,
      },
    }),
  ]);

  const upcomingTrips = await prisma.trip.findMany({
    where: {
      agencyId,
      status: "SCHEDULED",
      departureTime: { gte: new Date() },
    },

    include: {
      route: {
        include: {
          originBranch: true,
          destinationBranch: true,
        },
      },

      vehicle: true,

      _count: {
        select: { bookings: true },
      },
    },

    orderBy: {
      departureTime: "asc",
    },

    take: 5,
  });

  const recentBookings = await prisma.booking.findMany({
    where: {
      trip: { agencyId },
    },

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

    take: 5,
  });

  return {
    trips: {
      total: totalTrips,
      scheduled: scheduledTrips,
      departed: departedTrips,
      arrived: arrivedTrips,
      cancelled: cancelledTrips,
    },

    bookings: {
      total: totalBookings,
      pending: pendingBookings,
      confirmed: confirmedBookings,
      completed: completedBookings,
      cancelled: cancelledBookings,
    },

    luggage: {
      total: totalLuggage,
      inTransit: inTransitLuggage,
      delivered: deliveredLuggage,
    },

    parcels: {
      total: totalParcels,
      inTransit: inTransitParcels,
      delivered: deliveredParcels,
    },

    revenue: {
      successfulPayments:
        revenueAggregate._sum.amount ?? 0,
    },

    upcomingTrips,
    recentBookings,
  };
};

export const getAgencyTrips = async (
  agencyId: string
) => {
  return prisma.trip.findMany({
    where: {
      agencyId,
    },

    include: {
      agency: true,

      route: {
        include: {
          originBranch: true,
          destinationBranch: true,
        },
      },

      vehicle: true,

      _count: {
        select: {
          bookings: true,
          parcels: true,
        },
      },
    },

    orderBy: {
      departureTime: "desc",
    },
  });
};

export const getAgencyBookings = async (
  agencyId: string
) => {
  return prisma.booking.findMany({
    where: {
      trip: {
        agencyId,
      },
    },

    include: bookingInclude,

    orderBy: {
      createdAt: "desc",
    },
  });
};

export const getAgencyLuggage = async (
  agencyId: string
) => {
  return prisma.luggage.findMany({
    where: {
      booking: {
        trip: {
          agencyId,
        },
      },
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

export const getAgencyParcels = async (
  agencyId: string
) => {
  return prisma.parcel.findMany({
    where: {
      OR: [
        { originBranch: { agencyId } },
        { destinationBranch: { agencyId } },
      ],
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
