import prisma from "../../lib/prisma";

interface CreateBookingInput {
  userId: string;
  tripId: string;
  numberOfSeats: number;
}

const generateBookingReference = () => {
  const timestamp = Date.now()
    .toString(36)
    .toUpperCase();

  const randomPart = Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase();

  return `EG-${timestamp}-${randomPart}`;
};

export const getTripForBooking = async (
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

      vehicle: true,
    },
  });
};

export const createBooking = async (
  data: CreateBookingInput
) => {
  return prisma.$transaction(
    async (tx) => {
      const trip =
        await tx.trip.findUnique({
          where: {
            id: data.tripId,
          },
        });

      if (!trip) {
        throw new Error(
          "Trip not found"
        );
      }

      if (
        trip.status !== "SCHEDULED"
      ) {
        throw new Error(
          "Only scheduled trips can be booked"
        );
      }

      if (
        trip.departureTime <=
        new Date()
      ) {
        throw new Error(
          "Past trips cannot be booked"
        );
      }

      if (
        trip.availableSeats <
        data.numberOfSeats
      ) {
        throw new Error(
          "Not enough seats are available"
        );
      }

      const tripAmount =
        Number(trip.price) *
        data.numberOfSeats;

      const bookingReference =
        generateBookingReference();

      const updatedTrip =
        await tx.trip.updateMany({
          where: {
            id: data.tripId,

            status: "SCHEDULED",

            availableSeats: {
              gte: data.numberOfSeats,
            },
          },

          data: {
            availableSeats: {
              decrement:
                data.numberOfSeats,
            },
          },
        });

      if (
        updatedTrip.count !== 1
      ) {
        throw new Error(
          "The requested seats are no longer available"
        );
      }

      const booking =
        await tx.booking.create({
          data: {
            bookingReference,

            numberOfSeats:
              data.numberOfSeats,

            tripAmount,

            taxiPickupAmount: 0,
            taxiDropoffAmount: 0,

            totalAmount:
              tripAmount,

            status: "PENDING",

            userId: data.userId,
            tripId: data.tripId,
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

                vehicle: true,
              },
            },

            journey: true,
            payments: true,
            ticket: true,
            luggage: true,
          },
        });

      return booking;
    }
  );
};

export const getUserBookings =
  async (userId: string) => {
    return prisma.booking.findMany({
      where: {
        userId,
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

            vehicle: true,
          },
        },

        journey: true,
        payments: true,
        ticket: true,
        luggage: true,
      },

      orderBy: {
        createdAt: "desc",
      },
    });
  };

export const getBookingById =
  async (bookingId: string) => {
    return prisma.booking.findUnique({
      where: {
        id: bookingId,
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

            vehicle: true,
          },
        },

        journey: {
          include: {
            taxiAssignments: {
              include: {
                provider: true,
              },
            },
          },
        },

        payments: true,
        ticket: true,
        luggage: true,
      },
    });
  };

export const cancelBooking = async (
  bookingId: string
) => {
  return prisma.$transaction(
    async (tx) => {
      const booking =
        await tx.booking.findUnique({
          where: {
            id: bookingId,
          },

          include: {
            trip: true,
            journey: true,
          },
        });

      if (!booking) {
        throw new Error(
          "Booking not found"
        );
      }

      if (
        booking.status ===
        "CANCELLED"
      ) {
        throw new Error(
          "Booking is already cancelled"
        );
      }

      if (
        booking.status ===
        "COMPLETED"
      ) {
        throw new Error(
          "A completed booking cannot be cancelled"
        );
      }

      if (
        booking.trip.departureTime <=
        new Date()
      ) {
        throw new Error(
          "A booking cannot be cancelled after the trip departure time"
        );
      }

      if (
        booking.journey &&
        booking.journey.status !==
          "PENDING" &&
        booking.journey.status !==
          "CONFIRMED"
      ) {
        throw new Error(
          "This booking cannot be cancelled because the door-to-door journey is already in progress"
        );
      }

      const cancelledBooking =
        await tx.booking.update({
          where: {
            id: bookingId,
          },

          data: {
            status: "CANCELLED",
          },
        });

      await tx.trip.update({
        where: {
          id: booking.tripId,
        },

        data: {
          availableSeats: {
            increment:
              booking.numberOfSeats,
          },
        },
      });

      if (booking.journey) {
        await tx.doorToDoorJourney.update({
          where: {
            id:
              booking.journey.id,
          },

          data: {
            status: "CANCELLED",
          },
        });
      }

      return cancelledBooking;
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
      },
    });
  };

type StaffBookingStatus =
  | "CANCELLED"
  | "COMPLETED";

// Only these transitions are permitted, so a booking can never move
// backwards or be confirmed by hand.
const ALLOWED_BOOKING_TRANSITIONS: Record<
  StaffBookingStatus,
  string[]
> = {
  CANCELLED: ["PENDING", "CONFIRMED"],
  COMPLETED: ["CONFIRMED"],
};

export const updateBookingStatus =
  async (
    bookingId: string,
    status: StaffBookingStatus
  ) => {
    return prisma.$transaction(
      async (tx) => {
        const booking =
          await tx.booking.findUnique({
            where: {
              id: bookingId,
            },

            include: {
              trip: true,
              journey: true,
              ticket: true,
            },
          });

        if (!booking) {
          throw new Error("Booking not found");
        }

        const allowedFrom =
          ALLOWED_BOOKING_TRANSITIONS[status];

        if (
          !allowedFrom.includes(
            booking.status
          )
        ) {
          throw new Error(
            `A ${booking.status.toLowerCase()} booking cannot be marked as ${status.toLowerCase()}`
          );
        }

        if (
          status === "CANCELLED" &&
          booking.trip.departureTime <=
            new Date()
        ) {
          throw new Error(
            "A booking cannot be cancelled after the trip departure time"
          );
        }

        await tx.booking.update({
          where: {
            id: bookingId,
          },

          data: {
            status,
          },
        });

        if (status === "CANCELLED") {
          // Releasing the seat keeps availability consistent, and
          // the journey and ticket must stop with the booking.
          await tx.trip.update({
            where: {
              id: booking.tripId,
            },

            data: {
              availableSeats: {
                increment:
                  booking.numberOfSeats,
              },
            },
          });

          if (booking.journey) {
            await tx.doorToDoorJourney.update({
              where: {
                id: booking.journey.id,
              },

              data: {
                status: "CANCELLED",
              },
            });
          }

          if (booking.ticket) {
            await tx.ticket.update({
              where: {
                id: booking.ticket.id,
              },

              data: {
                status: "CANCELLED",
              },
            });
          }
        }

        if (
          status === "COMPLETED" &&
          booking.ticket &&
          booking.ticket.status ===
            "ACTIVE"
        ) {
          // A completed journey means the ticket was used.
          await tx.ticket.update({
            where: {
              id: booking.ticket.id,
            },

            data: {
              status: "USED",
              usedAt: new Date(),
            },
          });
        }

        return tx.booking.findUnique({
          where: {
            id: bookingId,
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
      }
    );
  };