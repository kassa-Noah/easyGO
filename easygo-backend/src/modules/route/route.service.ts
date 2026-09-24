import prisma from "../../lib/prisma";

interface CreateRouteInput {
  originBranchId: string;
  destinationBranchId: string;
  distanceKm?: number;
  estimatedDurationMinutes?: number;
  baseFare: number;
}

interface UpdateRouteInput {
  originBranchId?: string;
  destinationBranchId?: string;
  distanceKm?: number;
  estimatedDurationMinutes?: number;
  baseFare?: number;
  isActive?: boolean;
}

export const getAllRoutes = async () => {
  return prisma.route.findMany({
    where: {
      isActive: true,
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
    orderBy: {
      createdAt: "desc",
    },
  });
};

export const getRouteById = async (routeId: string) => {
  return prisma.route.findUnique({
    where: {
      id: routeId,
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

export const findExistingRoute = async (
  originBranchId: string,
  destinationBranchId: string
) => {
  return prisma.route.findFirst({
    where: {
      originBranchId,
      destinationBranchId,
    },
  });
};

export const createRoute = async (data: CreateRouteInput) => {
  return prisma.route.create({
    data,
    include: {
      originBranch: true,
      destinationBranch: true,
    },
  });
};

export const updateRoute = async (
  routeId: string,
  data: UpdateRouteInput
) => {
  return prisma.route.update({
    where: {
      id: routeId,
    },
    data,
    include: {
      originBranch: true,
      destinationBranch: true,
    },
  });
};

export const getBranchById = async (branchId: string) => {
  return prisma.agencyBranch.findUnique({
    where: {
      id: branchId,
    },
  });
};