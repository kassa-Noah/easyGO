import prisma from "../../lib/prisma";

interface CreateTripInput {
  departureTime: string;
  arrivalTime?: string;

  price: number;

  totalSeats: number;

  agencyId: string;
  routeId: string;
  vehicleId?: string;
}

interface UpdateTripInput {
  departureTime?: string;
  arrivalTime?: string;

  price?: number;

  totalSeats?: number;

  vehicleId?: string | null;

  status?:
    | "SCHEDULED"
    | "BOARDING"
    | "DEPARTED"
    | "ARRIVED"
    | "CANCELLED";
}

export const getAllTrips = async () => {
  return prisma.trip.findMany({
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
};

export const getTripById = async (tripId: string) => {
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

export const getAgencyById = async (agencyId: string) => {
  return prisma.agency.findUnique({
    where: {
      id: agencyId,
    },
  });
};

export const getRouteById = async (routeId: string) => {
  return prisma.route.findUnique({
    where: {
      id: routeId,
    },

    include: {
      originBranch: true,
      destinationBranch: true,
    },
  });
};

export const getVehicleById = async (vehicleId: string) => {
  return prisma.vehicle.findUnique({
    where: {
      id: vehicleId,
    },
  });
};

export const getAgencyStaffMembership = async (
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

export const createTrip = async (data: CreateTripInput) => {
  return prisma.trip.create({
    data: {
      departureTime: new Date(data.departureTime),

      arrivalTime: data.arrivalTime
        ? new Date(data.arrivalTime)
        : undefined,

      price: data.price,

      totalSeats: data.totalSeats,
      availableSeats: data.totalSeats,

      agencyId: data.agencyId,
      routeId: data.routeId,
      vehicleId: data.vehicleId,
    },

    include: {
      agency: true,
      route: true,
      vehicle: true,
    },
  });
};

export const updateTrip = async (
  tripId: string,
  data: UpdateTripInput
) => {
  const updateData: any = {
    ...data,
  };

  if (data.departureTime) {
    updateData.departureTime = new Date(data.departureTime);
  }

  if (data.arrivalTime) {
    updateData.arrivalTime = new Date(data.arrivalTime);
  }

  return prisma.trip.update({
    where: {
      id: tripId,
    },

    data: updateData,

    include: {
      agency: true,
      route: true,
      vehicle: true,
    },
  });
};