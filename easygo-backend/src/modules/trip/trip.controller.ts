import { Request, Response } from "express";

import { messageOf } from "../../lib/error-message";
import { notifySafely } from "../notification/notification.service";
import { listTripPassengerUserIds } from "../booking/booking.service";

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

/** The heading a passenger sees for each state a trip can move to. */
const tripStatusTitle = (status: string) => {
  switch (status) {
    case "BOARDING":
      return "Your trip is boarding";
    case "DEPARTED":
      return "Your trip has departed";
    case "ARRIVED":
      return "Your trip has arrived";
    case "CANCELLED":
      return "Your trip was cancelled";
    default:
      return "Your trip was updated";
  }
};

/**
 * What the passenger needs to do about it, if anything.
 *
 * A cancellation is the one state someone has to act on, so it says so
 * instead of leaving them to work it out from the word "cancelled".
 */
const tripStatusMessage = (status: string, route: string) => {
  switch (status) {
    case "BOARDING":
      return `The trip ${route} is boarding now. Be at the departure point.`;
    case "DEPARTED":
      return `The trip ${route} has departed.`;
    case "ARRIVED":
      return `The trip ${route} has arrived.`;
    case "CANCELLED":
      return (
        `The trip ${route} was cancelled by the agency. ` +
        `Contact the agency to arrange another journey.`
      );
    default:
      return `The trip ${route} is now ${status.toLowerCase()}.`;
  }
};

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

    // Passengers are told when the trip they hold a booking on actually moves,
    // and only then: editing a price or a departure time is not news, and
    // notifying on every save would make the notifications worthless.
    if (
      validatedData.status &&
      validatedData.status !== existingTrip.status
    ) {
      const route =
        `${existingTrip.route.originBranch.city} → ` +
        `${existingTrip.route.destinationBranch.city}`;

      const passengerIds = await listTripPassengerUserIds(
        tripId
      );

      for (const passengerId of passengerIds) {
        await notifySafely({
          userId: passengerId,

          title: tripStatusTitle(validatedData.status),

          message: tripStatusMessage(
            validatedData.status,
            route
          ),

          type: "TRIP",

          referenceType: "TRIP",
          referenceId: tripId,
        });
      }
    }

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