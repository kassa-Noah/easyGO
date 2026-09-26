import {
  Request,
  Response,
} from "express";

import { messageOf } from "../../lib/error-message";

import {
  createParcel,
  getAgencyStaffMembership,
  getBranchById,
  getParcelById,
  getParcelByTrackingNumber,
  getRecipientUser,
  getTripForParcel,
  getUserParcels,
  updateParcelStatus,
} from "./parcel.service";

import {
  createParcelSchema,
  updateParcelStatusSchema,
} from "./parcel.schema";

import {
  notifySafely,
} from "../notification/notification.service";

export const registerParcel = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData =
      createParcelSchema.parse(
        req.body
      );

    if (
      validatedData.originBranchId ===
      validatedData.destinationBranchId
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Origin and destination branches must be different",
      });
    }

    const originBranch =
      await getBranchById(
        validatedData.originBranchId
      );

    if (
      !originBranch ||
      !originBranch.isActive ||
      !originBranch.agency.isActive
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Origin branch is not available",
      });
    }

    const destinationBranch =
      await getBranchById(
        validatedData.destinationBranchId
      );

    if (
      !destinationBranch ||
      !destinationBranch.isActive ||
      !destinationBranch.agency.isActive
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Destination branch is not available",
      });
    }

    if (
      validatedData.recipientUserId
    ) {
      const recipient =
        await getRecipientUser(
          validatedData.recipientUserId
        );

      if (
        !recipient ||
        !recipient.isActive
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Recipient user is not available",
        });
      }
    }

    if (
      validatedData.tripId
    ) {
      const trip =
        await getTripForParcel(
          validatedData.tripId
        );

      if (!trip) {
        return res.status(404).json({
          success: false,
          message:
            "Trip not found",
        });
      }

      if (
        trip.status !==
        "SCHEDULED"
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Only scheduled trips can receive a parcel",
        });
      }

      if (
        trip.departureTime <=
        new Date()
      ) {
        return res.status(400).json({
          success: false,
          message:
            "A parcel cannot be assigned to a past trip",
        });
      }

      if (
        trip.route.originBranchId !==
          validatedData.originBranchId ||
        trip.route.destinationBranchId !==
          validatedData.destinationBranchId
      ) {
        return res.status(400).json({
          success: false,
          message:
            "The selected trip does not match the parcel route",
        });
      }

      if (
        trip.agencyId !==
        originBranch.agencyId
      ) {
        return res.status(400).json({
          success: false,
          message:
            "The selected trip does not belong to the origin agency",
        });
      }
    }

    const parcel =
      await createParcel({
        ...validatedData,

        senderId:
          req.user!.userId,
      });

    return res.status(201).json({
      success: true,
      message:
        "Parcel registered successfully",
      data: parcel,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to register parcel",
    });
  }
};

export const listMyParcels = async (
  req: Request,
  res: Response
) => {
  try {
    const parcels =
      await getUserParcels(
        req.user!.userId
      );

    return res.status(200).json({
      success: true,
      count:
        parcels.length,
      data:
        parcels,
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

export const getParcel = async (
  req: Request,
  res: Response
) => {
  try {
    const parcel =
      await getParcelById(
        String(
          req.params.id
        )
      );

    if (!parcel) {
      return res.status(404).json({
        success: false,
        message:
          "Parcel not found",
      });
    }

    if (
      req.user!.role ===
      "CUSTOMER"
    ) {
      const isSender =
        parcel.senderId ===
        req.user!.userId;

      const isRecipient =
        parcel.recipientUserId ===
        req.user!.userId;

      if (
        !isSender &&
        !isRecipient
      ) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to view this parcel",
        });
      }
    }

    if (
      req.user!.role ===
      "AGENCY_STAFF"
    ) {
      const originMembership =
        await getAgencyStaffMembership(
          req.user!.userId,
          parcel.originBranch
            .agencyId
        );

      const destinationMembership =
        await getAgencyStaffMembership(
          req.user!.userId,
          parcel.destinationBranch
            .agencyId
        );

      if (
        !originMembership &&
        !destinationMembership
      ) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to view this parcel",
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: parcel,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to retrieve parcel",
    });
  }
};

export const trackParcel = async (
  req: Request,
  res: Response
) => {
  try {
    const trackingNumber =
      String(
        req.params.trackingNumber
      );

    const parcel =
      await getParcelByTrackingNumber(
        trackingNumber
      );

    if (!parcel) {
      return res.status(404).json({
        success: false,
        message:
          "Parcel tracking number not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: parcel,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        messageOf(error) ||
        "Unable to track parcel",
    });
  }
};

export const changeParcelStatus =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const parcelId =
        String(
          req.params.id
        );

      const parcel =
        await getParcelById(
          parcelId
        );

      if (!parcel) {
        return res.status(404).json({
          success: false,
          message:
            "Parcel not found",
        });
      }

      if (
        req.user!.role ===
        "AGENCY_STAFF"
      ) {
        const originMembership =
          await getAgencyStaffMembership(
            req.user!.userId,
            parcel.originBranch
              .agencyId
          );

        const destinationMembership =
          await getAgencyStaffMembership(
            req.user!.userId,
            parcel.destinationBranch
              .agencyId
          );

        if (
          !originMembership &&
          !destinationMembership
        ) {
          return res.status(403).json({
            success: false,
            message:
              "You are not authorized to update this parcel",
          });
        }
      }

      const validatedData =
        updateParcelStatusSchema.parse(
          req.body
        );

      const updatedParcel =
        await updateParcelStatus({
          parcelId,

          status:
            validatedData.status,

          location:
            validatedData.location,

          description:
            validatedData.description,

          updatedById:
            req.user!.userId,
        });

      // The sender is the customer who registered the parcel, so they are the
      // one waiting to hear that it moved.
      await notifySafely({
        userId: parcel.senderId,

        title: "Parcel updated",

        message:
          `Parcel ${parcel.trackingNumber} is now ` +
          `${validatedData.status.toLowerCase().split("_").join(" ")}.`,

        type: "PARCEL",
      });

      return res.status(200).json({
        success: true,
        message:
          "Parcel status updated successfully",
        data:
          updatedParcel,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message:
          messageOf(error) ||
          "Unable to update parcel status",
      });
    }
  };