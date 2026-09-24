import prisma from "../../lib/prisma";

interface CreateAgencyInput {
  name: string;
  description?: string;
  email?: string;
  phone?: string;
  logoUrl?: string;
}

interface UpdateAgencyInput {
  name?: string;
  description?: string;
  email?: string;
  phone?: string;
  logoUrl?: string;
  isActive?: boolean;
}

interface BranchInput {
  name: string;
  city: string;
  address: string;
  latitude: number;
  longitude: number;
  phone?: string;
}

interface UpdateBranchInput {
  name?: string;
  city?: string;
  address?: string;
  latitude?: number;
  longitude?: number;
  phone?: string;
}

export const getAllAgencies = async () => {
  return prisma.agency.findMany({
    where: {
      isActive: true,
    },
    include: {
      branches: true,
    },
    orderBy: {
      name: "asc",
    },
  });
};

export const getAgencyById = async (agencyId: string) => {
  return prisma.agency.findUnique({
    where: {
      id: agencyId,
    },
    include: {
      branches: true,
    },
  });
};

export const createAgency = async (data: CreateAgencyInput) => {
  return prisma.agency.create({
    data,
  });
};

export const updateAgency = async (
  agencyId: string,
  data: UpdateAgencyInput
) => {
  return prisma.agency.update({
    where: {
      id: agencyId,
    },
    data,
  });
};

export const getAgencyBranches = async (agencyId: string) => {
  return prisma.agencyBranch.findMany({
    where: {
      agencyId,
    },
    orderBy: {
      city: "asc",
    },
  });
};

export const createAgencyBranch = async (
  agencyId: string,
  data: BranchInput
) => {
  return prisma.agencyBranch.create({
    data: {
      agencyId,
      ...data,
    },
  });
};

export const updateAgencyBranch = async (
  branchId: string,
  data: UpdateBranchInput
) => {
  return prisma.agencyBranch.update({
    where: {
      id: branchId,
    },
    data,
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

export const getBranchById = async (branchId: string) => {
  return prisma.agencyBranch.findUnique({
    where: {
      id: branchId,
    },
  });
};