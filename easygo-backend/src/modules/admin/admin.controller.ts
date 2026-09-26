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
  getDashboardStatistics,
} from "./admin.service";

import {
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