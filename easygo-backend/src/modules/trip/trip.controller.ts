import { Request, Response } from "express";

import { messageOf } from "../../lib/error-message";

import {
  createTrip,
  getAgencyById,
  getAgencyStaffMembership,
  getAllTrips,
  getRouteById,
  getTripById,
  getVehicleById,
  updateTrip,
} from "./trip.service";

import {
  createTripSchema,
  updateTripSchema,
} from "./trip.schema";

const canManageAgencyTrips = async (
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

  return !!membership;
};

export const listTrips = async (
  _req: Request,
  res: Response
) => {
  try {
    const trips = await getAllTrips();

    return res.status(200).json({
      success: true,
      data: trips,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: messageOf(error) || "Unable to retrieve trips",
    });
  }
};

export const getTrip = async (
  req: Request,
  res: Response
) => {
  try {
    const tripId = String(req.params.id);

    const trip = await getTripById(tripId);

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: trip,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: messageOf(error) || "Unable to retrieve trip",
    });
  }
};

export const addTrip = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData = createTripSchema.parse(req.body);

    const allowed = await canManageAgencyTrips(
      req.user!.userId,
      req.user!.role,
      validatedData.agencyId
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to create trips for this agency",
      });
    }

    const agency = await getAgencyById(
      validatedData.agencyId
    );

    if (!agency) {
      return res.status(404).json({
        success: false,
        message: "Agency not found",
      });
    }

    const route = await getRouteById(
      validatedData.routeId
    );

    if (!route) {
      return res.status(404).json({
        success: false,
        message: "Route not found",
      });
    }

    if (
      route.originBranch.agencyId !==
        validatedData.agencyId ||
      route.destinationBranch.agencyId !==
        validatedData.agencyId
    ) {
      return res.status(400).json({
        success: false,
        message:
          "The selected route does not belong to this agency",
      });
    }

    if (validatedData.vehicleId) {
      const vehicle = await getVehicleById(
        validatedData.vehicleId
      );

      if (!vehicle) {
        return res.status(404).json({
          success: false,
          message: "Vehicle not found",
        });
      }

      if (vehicle.agencyId !== validatedData.agencyId) {
        return res.status(400).json({
          success: false,
          message:
            "Vehicle does not belong to this agency",
        });
      }

      if (
        validatedData.totalSeats >
        vehicle.capacity
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Trip seats cannot exceed vehicle capacity",
        });
      }
    }

    const departure = new Date(
      validatedData.departureTime
    );

    if (departure <= new Date()) {
      return res.status(400).json({
        success: false,
        message:
          "Departure time must be in the future",
      });
    }

    if (validatedData.arrivalTime) {
      const arrival = new Date(
        validatedData.arrivalTime
      );

      if (arrival <= departure) {
        return res.status(400).json({
          success: false,
          message:
            "Arrival time must be after departure time",
        });
      }
    }

    const trip = await createTrip(validatedData);

    return res.status(201).json({
      success: true,
      message: "Trip created successfully",
      data: trip,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: messageOf(error) || "Unable to create trip",
    });
  }
};

export const editTrip = async (
  req: Request,
  res: Response
) => {
  try {
    const tripId = String(req.params.id);

    const existingTrip = await getTripById(
      tripId
    );

    if (!existingTrip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    const allowed = await canManageAgencyTrips(
      req.user!.userId,
      req.user!.role,
      existingTrip.agencyId
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to manage this trip",
      });
    }

    const validatedData = updateTripSchema.parse(
      req.body
    );

    if (validatedData.vehicleId) {
      const vehicle = await getVehicleById(
        validatedData.vehicleId
      );

      if (!vehicle) {
        return res.status(404).json({
          success: false,
          message: "Vehicle not found",
        });
      }

      if (
        vehicle.agencyId !== existingTrip.agencyId
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Vehicle does not belong to this agency",
        });
      }
    }

    const trip = await updateTrip(
      tripId,
      validatedData
    );

    return res.status(200).json({
      success: true,
      message: "Trip updated successfully",
      data: trip,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: messageOf(error) || "Unable to update trip",
    });
  }
};