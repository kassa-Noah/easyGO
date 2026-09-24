import prisma from "../../lib/prisma";

interface SearchTripsInput {
  originCity: string;
  destinationCity: string;
  travelDate: string;
  agencyId?: string;
}

export const searchTrips = async (data: SearchTripsInput) => {
  const startOfDay = new Date(`${data.travelDate}T00:00:00.000Z`);
  const endOfDay = new Date(`${data.travelDate}T23:59:59.999Z`);

  const trips = await prisma.trip.findMany({
    where: {
      departureTime: {
        gte: startOfDay,
        lte: endOfDay,
      },

      status: "SCHEDULED",

      availableSeats: {
        gt: 0,
      },

      ...(data.agencyId && {
        agencyId: data.agencyId,
      }),

      route: {
        is: {
          isActive: true,

          originBranch: {
            is: {
              city: {
                equals: data.originCity,
                mode: "insensitive",
              },
              isActive: true,
            },
          },

          destinationBranch: {
            is: {
              city: {
                equals: data.destinationCity,
                mode: "insensitive",
              },
              isActive: true,
            },
          },
        },
      },
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

    orderBy: {
      departureTime: "asc",
    },
  });

  return trips;
};