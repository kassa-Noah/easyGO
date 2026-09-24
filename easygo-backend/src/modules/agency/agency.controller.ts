import { Request, Response } from "express";

import {
  createAgency,
  createAgencyBranch,
  getAgencyBranches,
  getAgencyById,
  getAgencyStaffMembership,
  getAllAgencies,
  getBranchById,
  updateAgency,
  updateAgencyBranch,
} from "./agency.service";

import {
  createAgencySchema,
  createBranchSchema,
  updateAgencySchema,
  updateBranchSchema,
} from "./agency.schema";

const canManageAgency = async (
  userId: string,
  role: string,
  agencyId: string
) => {
  if (role === "ADMIN") {
    return true;
  }

  if (role !== "AGENCY_STAFF") {
    return false;
  }

  const membership = await getAgencyStaffMembership(
    userId,
    agencyId
  );

  if (!membership) {
    return false;
  }

  return membership.role === "MANAGER";
};

export const listAgencies = async (
  _req: Request,
  res: Response
) => {
  try {
    const agencies = await getAllAgencies();

    return res.status(200).json({
      success: true,
      data: agencies,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: error.message || "Unable to retrieve agencies",
    });
  }
};

export const getAgency = async (
  req: Request,
  res: Response
) => {
  try {
    const agencyId = String(req.params.id);

    const agency = await getAgencyById(agencyId);

    if (!agency) {
      return res.status(404).json({
        success: false,
        message: "Agency not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: agency,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: error.message || "Unable to retrieve agency",
    });
  }
};

export const addAgency = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData = createAgencySchema.parse(req.body);

    const agency = await createAgency(validatedData);

    return res.status(201).json({
      success: true,
      message: "Agency created successfully",
      data: agency,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: error.message || "Unable to create agency",
    });
  }
};

export const editAgency = async (
  req: Request,
  res: Response
) => {
  try {
    const agencyId = String(req.params.id);

    const allowed = await canManageAgency(
      req.user!.userId,
      req.user!.role,
      agencyId
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message: "You are not authorized to manage this agency",
      });
    }

    const validatedData = updateAgencySchema.parse(req.body);

    const agency = await updateAgency(
      agencyId,
      validatedData
    );

    return res.status(200).json({
      success: true,
      message: "Agency updated successfully",
      data: agency,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: error.message || "Unable to update agency",
    });
  }
};

export const listBranches = async (
  req: Request,
  res: Response
) => {
  try {
    const agencyId = String(req.params.id);

    const agency = await getAgencyById(agencyId);

    if (!agency) {
      return res.status(404).json({
        success: false,
        message: "Agency not found",
      });
    }

    const branches = await getAgencyBranches(agencyId);

    return res.status(200).json({
      success: true,
      data: branches,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: error.message || "Unable to retrieve branches",
    });
  }
};

export const addBranch = async (
  req: Request,
  res: Response
) => {
  try {
    const agencyId = String(req.params.id);

    const allowed = await canManageAgency(
      req.user!.userId,
      req.user!.role,
      agencyId
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message: "You are not authorized to manage this agency",
      });
    }

    const validatedData = createBranchSchema.parse(req.body);

    const branch = await createAgencyBranch(
      agencyId,
      validatedData
    );

    return res.status(201).json({
      success: true,
      message: "Agency branch created successfully",
      data: branch,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: error.message || "Unable to create branch",
    });
  }
};

export const editBranch = async (
  req: Request,
  res: Response
) => {
  try {
    const agencyId = String(req.params.id);
    const branchId = String(req.params.branchId);

    const branch = await getBranchById(branchId);

    if (!branch) {
      return res.status(404).json({
        success: false,
        message: "Branch not found",
      });
    }

    if (branch.agencyId !== agencyId) {
      return res.status(400).json({
        success: false,
        message: "Branch does not belong to this agency",
      });
    }

    const allowed = await canManageAgency(
      req.user!.userId,
      req.user!.role,
      agencyId
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message: "You are not authorized to manage this agency",
      });
    }

    const validatedData = updateBranchSchema.parse(req.body);

    const updatedBranch = await updateAgencyBranch(
      branchId,
      validatedData
    );

    return res.status(200).json({
      success: true,
      message: "Agency branch updated successfully",
      data: updatedBranch,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: error.message || "Unable to update branch",
    });
  }
};