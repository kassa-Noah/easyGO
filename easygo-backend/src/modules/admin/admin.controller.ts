import {
  Request,
  Response,
} from "express";

import {
  getAdminDashboard,
  getAllBookingsForAdmin,
  getAllLuggageForAdmin,
  getAllParcelsForAdmin,
  getAllPaymentsForAdmin,
  getDashboardStatistics,
} from "./admin.service";

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
        error.message ||
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
          error.message ||
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
          error.message ||
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
          error.message ||
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
          error.message ||
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
          error.message ||
          "Unable to retrieve luggage",
      });
    }
  };