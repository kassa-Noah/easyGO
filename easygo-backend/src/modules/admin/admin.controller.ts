import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";

import {
  getAdminDashboard,
  getAllBookingsForAdmin,
  getAllLuggageForAdmin,
  getAllParcelsForAdmin,
  getAllPaymentsForAdmin,
  getAllRoutesForAdmin,
  getAgencyStaffForAdmin,
  getDashboardStatistics,
  getStaffMembershipForUser,
  getUserForStaff,
  linkStaffToAgency,
  unlinkStaffFromAgency,
} from "./admin.service";

import { attachStaffSchema } from "./admin.schema";

import {
  getAgencyById,
  getAllAgenciesForAdmin,
} from "../agency/agency.service";

export const dashboard = async (
  _req: Request,
  res: Response
) => {
  try {
    const data =
      await getAdminDashboard();

    return res.status(200).json({
      success: true,
      data,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,

      message:
        messageOf(error) ||
        "Unable to retrieve admin dashboard",
    });
  }
};

export const dashboardStatistics =
  async (
    _req: Request,
    res: Response
  ) => {
    try {
      const data =
        await getDashboardStatistics();

      return res.status(200).json({
        success: true,
        data,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve dashboard statistics",
      });
    }
  };

export const listAllBookings =
  async (
    _req: Request,
    res: Response
  ) => {
    try {
      const bookings =
        await getAllBookingsForAdmin();

      return res.status(200).json({
        success: true,
        count: bookings.length,
        data: bookings,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve bookings",
      });
    }
  };

export const listAllPayments =
  async (
    _req: Request,
    res: Response
  ) => {
    try {
      const payments =
        await getAllPaymentsForAdmin();

      return res.status(200).json({
        success: true,
        count: payments.length,
        data: payments,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve payments",
      });
    }
  };

export const listAllParcels =
  async (
    _req: Request,
    res: Response
  ) => {
    try {
      const parcels =
        await getAllParcelsForAdmin();

      return res.status(200).json({
        success: true,
        count: parcels.length,
        data: parcels,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve parcels",
      });
    }
  };

export const listAllLuggage =
  async (
    _req: Request,
    res: Response
  ) => {
    try {
      const luggage =
        await getAllLuggageForAdmin();

      return res.status(200).json({
        success: true,
        count: luggage.length,
        data: luggage,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve luggage",
      });
    }
  };

/**
 * The staff of one agency.
 *
 * Membership is what decides whether an account can open the agency console
 * at all, so it belongs next to the agency rather than being inferred from a
 * count.
 */
export const listAgencyStaff =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const agencyId = String(req.params.agencyId);

      const agency = await getAgencyById(agencyId);

      if (!agency) {
        return res.status(404).json({
          success: false,
          message: "Agency not found",
        });
      }

      const staff = await getAgencyStaffForAdmin(agencyId);

      return res.status(200).json({
        success: true,
        count: staff.length,
        data: staff,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve the agency staff",
      });
    }
  };

/**
 * Attaches an existing account to an agency.
 *
 * There is no endpoint that creates an AGENCY_STAFF account and no endpoint
 * that changes a role, so without this an agency could be created but nobody
 * could ever operate it.
 */
export const attachStaff =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const agencyId = String(req.params.agencyId);

      const agency = await getAgencyById(agencyId);

      if (!agency) {
        return res.status(404).json({
          success: false,
          message: "Agency not found",
        });
      }

      const validatedData =
        attachStaffSchema.parse(req.body);

      const user = await getUserForStaff(
        validatedData.userId
      );

      if (!user) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      // An administrator already has every permission this membership would
      // grant, and attaching would demote them to AGENCY_STAFF.
      if (user.role === "ADMIN") {
        return res.status(400).json({
          success: false,
          message:
            "An administrator cannot be attached to an agency as staff",
        });
      }

      const membership =
        await getStaffMembershipForUser(
          validatedData.userId
        );

      if (membership) {
        return res.status(409).json({
          success: false,
          message:
            membership.agencyId === agencyId
              ? "This account is already staff of this agency"
              : `This account is already staff of ${membership.agency.name}`,
        });
      }

      const staff = await linkStaffToAgency(
        agencyId,
        validatedData.userId,
        validatedData.role ?? "AGENT"
      );

      return res.status(201).json({
        success: true,
        message: "Staff member added successfully",
        data: staff,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to add the staff member",
      });
    }
  };

/** Removes a staff member, putting the account back to CUSTOMER. */
export const detachStaff =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const userId = String(req.params.userId);

      const membership =
        await getStaffMembershipForUser(userId);

      if (!membership) {
        return res.status(404).json({
          success: false,
          message: "This account is not staff of any agency",
        });
      }

      await unlinkStaffFromAgency(userId);

      return res.status(200).json({
        success: true,
        message: "Staff member removed successfully",
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to remove the staff member",
      });
    }
  };

/**
 * Every agency, including the suspended ones.
 *
 * The public `GET /agencies` is filtered to active agencies, which is right for
 * the customer directory but wrong here: an administrator has to be able to see
 * a suspended agency in order to reactivate it.
 */
export const listAllAgencies =
  async (
    _req: Request,
    res: Response
  ) => {
    try {
      const agencies =
        await getAllAgenciesForAdmin();

      return res.status(200).json({
        success: true,
        count: agencies.length,
        data: agencies,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve agencies",
      });
    }
  };

/**
 * Every route, including the retired ones.
 *
 * The public `GET /routes` is filtered to `isActive: true`, so an
 * administrator could retire a route and then never see it again — the only
 * list that could bring it back would have dropped it. This endpoint is what
 * makes retiring a route a reversible decision.
 */
export const listAllRoutes =
  async (
    _req: Request,
    res: Response
  ) => {
    try {
      const routes =
        await getAllRoutesForAdmin();

      return res.status(200).json({
        success: true,
        count: routes.length,
        data: routes,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,

        message:
          messageOf(error) ||
          "Unable to retrieve routes",
      });
    }
  };