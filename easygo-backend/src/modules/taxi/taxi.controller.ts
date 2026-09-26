import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";

import {
  createTaxiAssignment,
  getAgencyStaffMembership,
  getExistingTaxiAssignment,
  getJourneyForTaxiAssignment,
  getJourneyTaxiAssignments,
  getTaxiAssignmentById,
  getTaxiProviderById,
  updateTaxiAssignment,
} from "./taxi.service";

import {
  assignTaxiSchema,
  updateTaxiAssignmentSchema,
} from "./taxi.schema";

type TaxiAssignmentStatus =
  | "PENDING"
  | "DRIVER_ASSIGNED"
  | "DRIVER_ARRIVING"
  | "PASSENGER_PICKED_UP"
  | "COMPLETED"
  | "CANCELLED";

const validStatusTransitions: Record<
  TaxiAssignmentStatus,
  TaxiAssignmentStatus[]
> = {
  PENDING: [
    "DRIVER_ASSIGNED",
    "CANCELLED",
  ],

  DRIVER_ASSIGNED: [
    "DRIVER_ARRIVING",
    "CANCELLED",
  ],

  DRIVER_ARRIVING: [
    "PASSENGER_PICKED_UP",
    "CANCELLED",
  ],

  PASSENGER_PICKED_UP: [
    "COMPLETED",
  ],

  COMPLETED: [],

  CANCELLED: [],
};

const canManageJourneyTaxi = async (
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

  const membership =
    await getAgencyStaffMembership(
      userId,
      agencyId
    );

  return Boolean(membership);
};

export const assignTaxi = async (
  req: Request,
  res: Response
) => {
  try {
    const journeyId = String(
      req.params.journeyId
    );

    const validatedData =
      assignTaxiSchema.parse(req.body);

    const journey =
      await getJourneyForTaxiAssignment(
        journeyId
      );

    if (!journey) {
      return res.status(404).json({
        success: false,
        message:
          "Door-to-door journey not found",
      });
    }

    const agencyId =
      journey.booking.trip.agencyId;

    const authorized =
      await canManageJourneyTaxi(
        req.user!.userId,
        req.user!.role,
        agencyId
      );

    if (!authorized) {
      return res.status(403).json({
        success: false,
        message:
          "You are not authorized to manage taxi assignments for this journey",
      });
    }

    if (
      journey.status === "CANCELLED" ||
      journey.status === "COMPLETED"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Taxi assignments cannot be created for a cancelled or completed journey",
      });
    }

    const provider =
      await getTaxiProviderById(
        validatedData.providerId
      );

    if (!provider) {
      return res.status(404).json({
        success: false,
        message:
          "Taxi provider not found",
      });
    }

    if (!provider.isActive) {
      return res.status(400).json({
        success: false,
        message:
          "Taxi provider is not active",
      });
    }

    const existingAssignment =
      await getExistingTaxiAssignment(
        journeyId,
        validatedData.segmentType
      );

    if (existingAssignment) {
      return res.status(409).json({
        success: false,
        message:
          "A taxi assignment already exists for this journey segment",
      });
    }

    let pickupAddress: string;
    let dropoffAddress: string;

    if (
      validatedData.segmentType ===
      "HOME_TO_DEPARTURE_AGENCY"
    ) {
      pickupAddress =
        journey.pickupAddress;

      dropoffAddress =
        journey.booking.trip.route
          .originBranch.address;
    } else {
      pickupAddress =
        journey.booking.trip.route
          .destinationBranch.address;

      dropoffAddress =
        journey.destinationAddress;
    }

    const assignment =
      await createTaxiAssignment({
        journeyId,

        providerId:
          validatedData.providerId,

        segmentType:
          validatedData.segmentType,

        pickupAddress,
        dropoffAddress,

        estimatedFare:
          validatedData.estimatedFare,
      });

    return res.status(201).json({
      success: true,
      message:
        "Taxi assignment created successfully",
      data: assignment,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to create taxi assignment",
    });
  }
};

export const listJourneyTaxiAssignments =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const journeyId = String(
        req.params.journeyId
      );

      const journey =
        await getJourneyForTaxiAssignment(
          journeyId
        );

      if (!journey) {
        return res.status(404).json({
          success: false,
          message:
            "Door-to-door journey not found",
        });
      }

      if (
        req.user!.role === "CUSTOMER"
      ) {
        if (
          journey.userId !==
          req.user!.userId
        ) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to view these taxi assignments",
          });
        }
      } else {
        const authorized =
          await canManageJourneyTaxi(
            req.user!.userId,
            req.user!.role,
            journey.booking.trip.agencyId
          );

        if (!authorized) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to view these taxi assignments",
          });
        }
      }

      const assignments =
        await getJourneyTaxiAssignments(
          journeyId
        );

      return res.status(200).json({
        success: true,
        count: assignments.length,
        data: assignments,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,
        message:
          messageOf(error) ||
          "Unable to retrieve taxi assignments",
      });
    }
  };

export const getTaxiAssignment =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const assignmentId = String(
        req.params.id
      );

      const assignment =
        await getTaxiAssignmentById(
          assignmentId
        );

      if (!assignment) {
        return res.status(404).json({
          success: false,
          message:
            "Taxi assignment not found",
        });
      }

      if (
        req.user!.role === "CUSTOMER"
      ) {
        if (
          assignment.journey.userId !==
          req.user!.userId
        ) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to view this taxi assignment",
          });
        }
      } else {
        const authorized =
          await canManageJourneyTaxi(
            req.user!.userId,
            req.user!.role,
            assignment.journey.booking.trip
              .agencyId
          );

        if (!authorized) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to view this taxi assignment",
          });
        }
      }

      return res.status(200).json({
        success: true,
        data: assignment,
      });
    } catch (error: any) {
      return res.status(500).json({
        success: false,
        message:
          messageOf(error) ||
          "Unable to retrieve taxi assignment",
      });
    }
  };

export const changeTaxiAssignment =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const assignmentId = String(
        req.params.id
      );

      const assignment =
        await getTaxiAssignmentById(
          assignmentId
        );

      if (!assignment) {
        return res.status(404).json({
          success: false,
          message:
            "Taxi assignment not found",
        });
      }

      const authorized =
        await canManageJourneyTaxi(
          req.user!.userId,
          req.user!.role,
          assignment.journey.booking.trip
            .agencyId
        );

      if (!authorized) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to update this taxi assignment",
        });
      }

      if (
        assignment.journey.status ===
          "CANCELLED" ||
        assignment.journey.status ===
          "COMPLETED"
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Taxi assignments cannot be modified for a cancelled or completed journey",
        });
      }

      const validatedData =
        updateTaxiAssignmentSchema.parse(
          req.body
        );

      if (validatedData.status) {
        const currentStatus =
          assignment.status as TaxiAssignmentStatus;

        const requestedStatus =
          validatedData.status as TaxiAssignmentStatus;

        if (
          currentStatus ===
          requestedStatus
        ) {
          return res.status(400).json({
            success: false,
            message:
              `Taxi assignment is already ${currentStatus}`,
          });
        }

        const allowedStatuses =
          validStatusTransitions[
            currentStatus
          ];

        if (
          !allowedStatuses.includes(
            requestedStatus
          )
        ) {
          return res.status(400).json({
            success: false,
            message:
              `Invalid taxi status transition: ${currentStatus} -> ${requestedStatus}`,
          });
        }
      }

      const updatedAssignment =
        await updateTaxiAssignment(
          assignmentId,
          validatedData
        );

      return res.status(200).json({
        success: true,
        message:
          "Taxi assignment updated successfully",
        data: updatedAssignment,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message:
          messageOf(error) ||
          "Unable to update taxi assignment",
      });
    }
  };