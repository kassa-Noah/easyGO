import prisma from "../../lib/prisma";

export const getDashboardStatistics =
  async () => {
    const [
      totalUsers,
      activeUsers,
      totalCustomers,
      totalAgencyStaff,

      totalAgencies,
      activeAgencies,

      totalTrips,
      scheduledTrips,
      completedTrips,

      totalBookings,
      pendingBookings,
      confirmedBookings,
      completedBookings,
      cancelledBookings,

      totalPayments,
      successfulPayments,
      pendingPayments,
      failedPayments,

      totalTickets,

      totalLuggage,
      deliveredLuggage,
      lostLuggage,

      totalParcels,
      deliveredParcels,
      collectedParcels,
      lostParcels,

      totalJourneys,
      completedJourneys,

      totalReviews,
      paymentAggregate,
    ] = await Promise.all([
      prisma.user.count(),

      prisma.user.count({
        where: {
          isActive: true,
        },
      }),

      prisma.user.count({
        where: {
          role: "CUSTOMER",
        },
      }),

      prisma.user.count({
        where: {
          role: "AGENCY_STAFF",
        },
      }),

      prisma.agency.count(),

      prisma.agency.count({
        where: {
          isActive: true,
        },
      }),

      prisma.trip.count(),

      prisma.trip.count({
        where: {
          status: "SCHEDULED",
        },
      }),

      prisma.trip.count({
        where: {
          status: "ARRIVED",
        },
      }),

      prisma.booking.count(),

      prisma.booking.count({
        where: {
          status: "PENDING",
        },
      }),

      prisma.booking.count({
        where: {
          status: "CONFIRMED",
        },
      }),

      prisma.booking.count({
        where: {
          status: "COMPLETED",
        },
      }),

      prisma.booking.count({
        where: {
          status: "CANCELLED",
        },
      }),

      prisma.payment.count(),

      prisma.payment.count({
        where: {
          status: "SUCCESSFUL",
        },
      }),

      prisma.payment.count({
        where: {
          status: "PENDING",
        },
      }),

      prisma.payment.count({
        where: {
          status: "FAILED",
        },
      }),

      prisma.ticket.count(),

      prisma.luggage.count(),

      prisma.luggage.count({
        where: {
          status: "DELIVERED",
        },
      }),

      prisma.luggage.count({
        where: {
          status: "LOST",
        },
      }),

      prisma.parcel.count(),

      prisma.parcel.count({
        where: {
          status: "DELIVERED",
        },
      }),

      prisma.parcel.count({
        where: {
          status: "COLLECTED",
        },
      }),

      prisma.parcel.count({
        where: {
          status: "LOST",
        },
      }),

      prisma.doorToDoorJourney.count(),

      prisma.doorToDoorJourney.count({
        where: {
          status: "COMPLETED",
        },
      }),

      prisma.review.count(),

      prisma.payment.aggregate({
        where: {
          status: "SUCCESSFUL",
        },

        _sum: {
          amount: true,
        },
      }),
    ]);

    return {
      users: {
        total: totalUsers,
        active: activeUsers,
        customers: totalCustomers,
        agencyStaff: totalAgencyStaff,
      },

      agencies: {
        total: totalAgencies,
        active: activeAgencies,
      },

      trips: {
        total: totalTrips,
        scheduled: scheduledTrips,
        arrived: completedTrips,
      },

      bookings: {
        total: totalBookings,
        pending: pendingBookings,
        confirmed: confirmedBookings,
        completed: completedBookings,
        cancelled: cancelledBookings,
      },

      payments: {
        total: totalPayments,
        successful: successfulPayments,
        pending: pendingPayments,
        failed: failedPayments,

        totalSuccessfulAmount:
          paymentAggregate._sum.amount ??
          0,
      },

      tickets: {
        total: totalTickets,
      },

      luggage: {
        total: totalLuggage,
        delivered: deliveredLuggage,
        lost: lostLuggage,
      },

      parcels: {
        total: totalParcels,
        delivered: deliveredParcels,
        collected: collectedParcels,
        lost: lostParcels,
      },

      journeys: {
        total: totalJourneys,
        completed: completedJourneys,
      },

      reviews: {
        total: totalReviews,
      },
    };
  };

export const getRecentBookings =
  async () => {
    return prisma.booking.findMany({
      take: 10,

      orderBy: {
        createdAt: "desc",
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
            agency: {
              select: {
                id: true,
                name: true,
              },
            },

            route: {
              include: {
                originBranch: {
                  select: {
                    id: true,
                    name: true,
                    city: true,
                  },
                },

                destinationBranch: {
                  select: {
                    id: true,
                    name: true,
                    city: true,
                  },
                },
              },
            },
          },
        },

        payments: true,
        ticket: true,
        journey: true,
      },
    });
  };

export const getRecentPayments =
  async () => {
    return prisma.payment.findMany({
      take: 10,

      orderBy: {
        createdAt: "desc",
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
              },
            },

            trip: {
              include: {
                agency: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
    });
  };

export const getRecentParcels =
  async () => {
    return prisma.parcel.findMany({
      take: 10,

      orderBy: {
        createdAt: "desc",
      },

      include: {
        sender: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            phone: true,
          },
        },

        recipientUser: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            phone: true,
          },
        },

        originBranch: {
          include: {
            agency: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },

        destinationBranch: {
          include: {
            agency: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },

        trip: {
          select: {
            id: true,
            departureTime: true,
            status: true,
          },
        },
      },
    });
  };

export const getRecentLuggage =
  async () => {
    return prisma.luggage.findMany({
      take: 10,

      orderBy: {
        createdAt: "desc",
      },

      include: {
        booking: {
          include: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                phone: true,
              },
            },

            trip: {
              include: {
                agency: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
    });
  };

export const getRecentUsers =
  async () => {
    return prisma.user.findMany({
      take: 10,

      orderBy: {
        createdAt: "desc",
      },

      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        phone: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  };

export const getAdminDashboard =
  async () => {
    const [
      statistics,
      recentBookings,
      recentPayments,
      recentParcels,
      recentLuggage,
      recentUsers,
    ] = await Promise.all([
      getDashboardStatistics(),
      getRecentBookings(),
      getRecentPayments(),
      getRecentParcels(),
      getRecentLuggage(),
      getRecentUsers(),
    ]);

    return {
      statistics,

      recentActivity: {
        bookings: recentBookings,
        payments: recentPayments,
        parcels: recentParcels,
        luggage: recentLuggage,
        users: recentUsers,
      },
    };
  };

export const getAllBookingsForAdmin =
  async () => {
    return prisma.booking.findMany({
      orderBy: {
        createdAt: "desc",
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
        journey: true,
        luggage: true,
      },
    });
  };

export const getAllPaymentsForAdmin =
  async () => {
    return prisma.payment.findMany({
      orderBy: {
        createdAt: "desc",
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
              },
            },
          },
        },
      },
    });
  };

/**
 * Every route, including the retired ones.
 *
 * `GET /routes` is public and filtered to `isActive: true`, which is right for
 * the customer-facing service list but wrong here: a route that an
 * administrator retires would disappear from the only list that could bring it
 * back. This one is unfiltered so retiring a route stays reversible.
 */
export const getAllRoutesForAdmin =
  async () => {
    return prisma.route.findMany({
      orderBy: {
        createdAt: "desc",
      },

      include: {
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
      },
    });
  };

export const getAllParcelsForAdmin =
  async () => {
    return prisma.parcel.findMany({
      orderBy: {
        createdAt: "desc",
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
  };

export const getAllLuggageForAdmin =
  async () => {
    return prisma.luggage.findMany({
      orderBy: {
        createdAt: "desc",
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