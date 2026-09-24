import prisma from "../../lib/prisma";

const generateTicketNumber = () => {
  const timestamp = Date.now()
    .toString(36)
    .toUpperCase();

  const randomPart = Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase();

  return `TKT-${timestamp}-${randomPart}`;
};

const generateQrCodeData = (
  ticketNumber: string,
  bookingId: string
) => {
  return JSON.stringify({
    type: "EASYGO_DIGITAL_TICKET",
    ticketNumber,
    bookingId,
  });
};

export const getBookingForTicket = async (
  bookingId: string
) => {
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

      payments: true,
      ticket: true,
      journey: true,
    },
  });
};

export const createTicket = async (
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
            payments: true,
            ticket: true,
          },
        });

      if (!booking) {
        throw new Error(
          "Booking not found"
        );
      }

      if (
        booking.status !==
        "CONFIRMED"
      ) {
        throw new Error(
          "Only confirmed bookings can receive a ticket"
        );
      }

      const successfulPayment =
        booking.payments.find(
          (payment) =>
            payment.status ===
            "SUCCESSFUL"
        );

      if (!successfulPayment) {
        throw new Error(
          "A successful payment is required before ticket generation"
        );
      }

      if (booking.ticket) {
        throw new Error(
          "A ticket already exists for this booking"
        );
      }

      const ticketNumber =
        generateTicketNumber();

      const qrCodeData =
        generateQrCodeData(
          ticketNumber,
          booking.id
        );

      return tx.ticket.create({
        data: {
          ticketNumber,
          qrCodeData,

          status: "ACTIVE",

          bookingId:
            booking.id,
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

                  vehicle: true,
                },
              },

              payments: true,
              journey: true,
            },
          },
        },
      });
    }
  );
};

export const getTicketById = async (
  ticketId: string
) => {
  return prisma.ticket.findUnique({
    where: {
      id: ticketId,
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

              vehicle: true,
            },
          },

          payments: true,
          journey: true,
        },
      },
    },
  });
};

export const getTicketByBookingId =
  async (bookingId: string) => {
    return prisma.ticket.findUnique({
      where: {
        bookingId,
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

                vehicle: true,
              },
            },

            payments: true,
            journey: true,
          },
        },
      },
    });
  };

export const getTicketByNumber = async (
  ticketNumber: string
) => {
  return prisma.ticket.findUnique({
    where: {
      ticketNumber,
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

              vehicle: true,
            },
          },
        },
      },
    },
  });
};

export const getUserTickets = async (
  userId: string
) => {
  return prisma.ticket.findMany({
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

              vehicle: true,
            },
          },
        },
      },
    },

    orderBy: {
      issuedAt: "desc",
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
        isActive: true,
      },
    });
  };