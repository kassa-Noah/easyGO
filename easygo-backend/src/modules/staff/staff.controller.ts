import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";

import {
  getAgencyBookings,
  getAgencyDashboard,
  getAgencyLuggage,
  getAgencyLuggageByTrackingNumber,
  getAgencyParcels,
  getAgencyTrips,
  getStaffMembership,
} from "./staff.service";

// Resolves the agency the signed-in staff member belongs to. The
// agency is never taken from the request, so one agency can never
// read another agency's records.
const resolveMembership = async (
  req: Request,
  res: Response
) => {
  const membership = await getStaffMembership(
    req.user!.userId
  );

  if (!membership) {
    res.status(403).json({
      success: false,
      message:
        "You are not linked to an active transport agency",
    });

    return null;
  }

  return membership;
};

export const getMyAgency = async (
  req: Request,
  res: Response
) => {
  try {
    const membership = await resolveMembership(
      req,
      res
    );

    if (!membership) {
      return;
    }

    return res.status(200).json({
      success: true,

      data: {
        staffRole: membership.role,
        agency: membership.agency,
      },
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,

      message:
        messageOf(error) ||
        "Unable to retrieve the agency",
    });
  }
};

export const getDashboard = async (
  req: Request,
  res: Response
) => {
  try {
    const membership = await resolveMembership(
      req,
      res
    );

    if (!membership) {
      return;
    }

    const dashboard = await getAgencyDashboard(
      membership.agencyId
    );

    return res.status(200).json({
      success: true,
      data: dashboard,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,

      message:
        messageOf(error) ||
        "Unable to retrieve the agency dashboard",
    });
  }
};

export const listTrips = async (
  req: Request,
  res: Response
) => {
  try {
    const membership = await resolveMembership(
      req,
      res
    );

    if (!membership) {
      return;
    }

    const trips = await getAgencyTrips(
      membership.agencyId
    );

    return res.status(200).json({
      success: true,
      count: trips.length,
      data: trips,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,

      message:
        messageOf(error) ||
        "Unable to retrieve the agency trips",
    });
  }
};

export const listBookings = async (
  req: Request,
  res: Response
) => {
  try {
    const membership = await resolveMembership(
      req,
      res
    );

    if (!membership) {
      return;
    }

    const bookings = await getAgencyBookings(
      membership.agencyId
    );

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
        "Unable to retrieve the agency bookings",
    });
  }
};

export const listLuggage = async (
  req: Request,
  res: Response
) => {
  try {
    const membership = await resolveMembership(
      req,
      res
    );

    if (!membership) {
      return;
    }

    const luggage = await getAgencyLuggage(
      membership.agencyId
    );

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
        "Unable to retrieve the agency luggage",
    });
  }
};

/// Resolves the code scanned off a piece of luggage.
///
/// Answers 404 both when no such bag exists and when the bag belongs to another
/// agency, with the same wording. Distinguishing them would turn a scan into a
/// way to confirm what a competitor is carrying.
///
export const findLuggage = async (
  req: Request,
  res: Response
) => {
  try {
    const membership = await resolveMembership(
      req,
      res
    );

    if (!membership) {
      return;
    }

    const trackingNumber = String(
      req.params.trackingNumber ?? ""
    ).trim();

    if (!trackingNumber) {
      return res.status(400).json({
        success: false,
        message:
          "A luggage tracking number is required",
      });
    }

    const luggage =
      await getAgencyLuggageByTrackingNumber(
        membership.agencyId,
        trackingNumber
      );

    if (!luggage) {
      return res.status(404).json({
        success: false,
        message:
          "No luggage with that tracking number belongs to your agency",
      });
    }

    return res.status(200).json({
      success: true,
      data: luggage,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,

      message:
        messageOf(error) ||
        "Unable to look up the luggage",
    });
  }
};

export const listParcels = async (
  req: Request,
  res: Response
) => {
  try {
    const membership = await resolveMembership(
      req,
      res
    );

    if (!membership) {
      return;
    }

    const parcels = await getAgencyParcels(
      membership.agencyId
    );

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
        "Unable to retrieve the agency parcels",
    });
  }
};
