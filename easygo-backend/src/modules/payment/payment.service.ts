import prisma from "../../lib/prisma";

type PaymentMethod =
  | "MOBILE_MONEY"
  | "CASH"
  | "CARD"
  | "SIMULATED";

type SimulatedPaymentResult =
  | "SUCCESSFUL"
  | "FAILED";

interface CreatePaymentInput {
  bookingId: string;
  method: PaymentMethod;
}

const generateTransactionReference = () => {
  const timestamp = Date.now()
    .toString(36)
    .toUpperCase();

  const randomPart = Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase();

  return `PAY-${timestamp}-${randomPart}`;
};

export const getBookingForPayment = async (
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

      payments: true,
    },
  });
};

export const getSuccessfulPaymentForBooking =
  async (
    bookingId: string
  ) => {
    return prisma.payment.findFirst({
      where: {
        bookingId,
        status: "SUCCESSFUL",
      },
    });
  };

export const getPendingPaymentForBooking =
  async (
    bookingId: string
  ) => {
    return prisma.payment.findFirst({
      where: {
        bookingId,
        status: "PENDING",
      },
    });
  };

export const createPayment = async (
  data: CreatePaymentInput
) => {
  return prisma.$transaction(
    async (tx) => {
      const booking =
        await tx.booking.findUnique({
          where: {
            id: data.bookingId,
          },

          include: {
            payments: true,
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
          "A cancelled booking cannot be paid"
        );
      }

      if (
        booking.status ===
        "COMPLETED"
      ) {
        throw new Error(
          "A completed booking cannot be paid"
        );
      }

      const successfulPayment =
        booking.payments.find(
          (payment) =>
            payment.status ===
            "SUCCESSFUL"
        );

      if (successfulPayment) {
        throw new Error(
          "This booking has already been paid"
        );
      }

      const pendingPayment =
        booking.payments.find(
          (payment) =>
            payment.status ===
            "PENDING"
        );

      if (pendingPayment) {
        throw new Error(
          "A payment is already pending for this booking"
        );
      }

      const transactionReference =
        generateTransactionReference();

      return tx.payment.create({
        data: {
          transactionReference,

          amount:
            booking.totalAmount,

          method:
            data.method,

          status:
            "PENDING",

          bookingId:
            booking.id,
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
        },
      });
    }
  );
};

export const getPaymentById = async (
  paymentId: string
) => {
  return prisma.payment.findUnique({
    where: {
      id: paymentId,
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
    },
  });
};

export const getPaymentsByBookingId =
  async (
    bookingId: string
  ) => {
    return prisma.payment.findMany({
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

export const completeSimulatedPayment =
  async (
    paymentId: string,
    result: SimulatedPaymentResult
  ) => {
    return prisma.$transaction(
      async (tx) => {
        const payment =
          await tx.payment.findUnique({
            where: {
              id: paymentId,
            },

            include: {
              booking: true,
            },
          });

        if (!payment) {
          throw new Error(
            "Payment not found"
          );
        }

        if (
          payment.method !==
          "SIMULATED"
        ) {
          throw new Error(
            "Only simulated payments can use this operation"
          );
        }

        if (
          payment.status !==
          "PENDING"
        ) {
          throw new Error(
            "Only a pending payment can be processed"
          );
        }

        if (
          payment.booking.status ===
          "CANCELLED"
        ) {
          throw new Error(
            "Payment cannot be completed because the booking is cancelled"
          );
        }

        if (
          payment.booking.status ===
          "COMPLETED"
        ) {
          throw new Error(
            "Payment cannot be completed because the booking is already completed"
          );
        }

        if (
          result === "FAILED"
        ) {
          return tx.payment.update({
            where: {
              id: payment.id,
            },

            data: {
              status:
                "FAILED",
            },

            include: {
              booking: true,
            },
          });
        }

        const existingSuccessfulPayment =
          await tx.payment.findFirst({
            where: {
              bookingId:
                payment.bookingId,

              status:
                "SUCCESSFUL",

              id: {
                not:
                  payment.id,
              },
            },
          });

        if (
          existingSuccessfulPayment
        ) {
          throw new Error(
            "This booking has already been paid"
          );
        }

        const paidAt =
          new Date();

        await tx.payment.update({
          where: {
            id: payment.id,
          },

          data: {
            status:
              "SUCCESSFUL",

            paidAt,
          },
        });

        if (
          payment.booking.status ===
          "PENDING"
        ) {
          await tx.booking.update({
            where: {
              id:
                payment.bookingId,
            },

            data: {
              status:
                "CONFIRMED",
            },
          });
        }

        return tx.payment.findUnique({
          where: {
            id:
              payment.id,
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