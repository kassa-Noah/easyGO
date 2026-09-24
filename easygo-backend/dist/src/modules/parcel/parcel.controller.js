"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.changeParcelStatus = exports.trackParcel = exports.getParcel = exports.listMyParcels = exports.registerParcel = void 0;
const parcel_service_1 = require("./parcel.service");
const parcel_schema_1 = require("./parcel.schema");
const registerParcel = async (req, res) => {
    try {
        const validatedData = parcel_schema_1.createParcelSchema.parse(req.body);
        if (validatedData.originBranchId ===
            validatedData.destinationBranchId) {
            return res.status(400).json({
                success: false,
                message: "Origin and destination branches must be different",
            });
        }
        const originBranch = await (0, parcel_service_1.getBranchById)(validatedData.originBranchId);
        if (!originBranch ||
            !originBranch.isActive ||
            !originBranch.agency.isActive) {
            return res.status(400).json({
                success: false,
                message: "Origin branch is not available",
            });
        }
        const destinationBranch = await (0, parcel_service_1.getBranchById)(validatedData.destinationBranchId);
        if (!destinationBranch ||
            !destinationBranch.isActive ||
            !destinationBranch.agency.isActive) {
            return res.status(400).json({
                success: false,
                message: "Destination branch is not available",
            });
        }
        if (validatedData.recipientUserId) {
            const recipient = await (0, parcel_service_1.getRecipientUser)(validatedData.recipientUserId);
            if (!recipient ||
                !recipient.isActive) {
                return res.status(400).json({
                    success: false,
                    message: "Recipient user is not available",
                });
            }
        }
        if (validatedData.tripId) {
            const trip = await (0, parcel_service_1.getTripForParcel)(validatedData.tripId);
            if (!trip) {
                return res.status(404).json({
                    success: false,
                    message: "Trip not found",
                });
            }
            if (trip.status !==
                "SCHEDULED") {
                return res.status(400).json({
                    success: false,
                    message: "Only scheduled trips can receive a parcel",
                });
            }
            if (trip.departureTime <=
                new Date()) {
                return res.status(400).json({
                    success: false,
                    message: "A parcel cannot be assigned to a past trip",
                });
            }
            if (trip.route.originBranchId !==
                validatedData.originBranchId ||
                trip.route.destinationBranchId !==
                    validatedData.destinationBranchId) {
                return res.status(400).json({
                    success: false,
                    message: "The selected trip does not match the parcel route",
                });
            }
            if (trip.agencyId !==
                originBranch.agencyId) {
                return res.status(400).json({
                    success: false,
                    message: "The selected trip does not belong to the origin agency",
                });
            }
        }
        const parcel = await (0, parcel_service_1.createParcel)({
            ...validatedData,
            senderId: req.user.userId,
        });
        return res.status(201).json({
            success: true,
            message: "Parcel registered successfully",
            data: parcel,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to register parcel",
        });
    }
};
exports.registerParcel = registerParcel;
const listMyParcels = async (req, res) => {
    try {
        const parcels = await (0, parcel_service_1.getUserParcels)(req.user.userId);
        return res.status(200).json({
            success: true,
            count: parcels.length,
            data: parcels,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve parcels",
        });
    }
};
exports.listMyParcels = listMyParcels;
const getParcel = async (req, res) => {
    try {
        const parcel = await (0, parcel_service_1.getParcelById)(String(req.params.id));
        if (!parcel) {
            return res.status(404).json({
                success: false,
                message: "Parcel not found",
            });
        }
        if (req.user.role ===
            "CUSTOMER") {
            const isSender = parcel.senderId ===
                req.user.userId;
            const isRecipient = parcel.recipientUserId ===
                req.user.userId;
            if (!isSender &&
                !isRecipient) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this parcel",
                });
            }
        }
        if (req.user.role ===
            "AGENCY_STAFF") {
            const originMembership = await (0, parcel_service_1.getAgencyStaffMembership)(req.user.userId, parcel.originBranch
                .agencyId);
            const destinationMembership = await (0, parcel_service_1.getAgencyStaffMembership)(req.user.userId, parcel.destinationBranch
                .agencyId);
            if (!originMembership &&
                !destinationMembership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to view this parcel",
                });
            }
        }
        return res.status(200).json({
            success: true,
            data: parcel,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve parcel",
        });
    }
};
exports.getParcel = getParcel;
const trackParcel = async (req, res) => {
    try {
        const trackingNumber = String(req.params.trackingNumber);
        const parcel = await (0, parcel_service_1.getParcelByTrackingNumber)(trackingNumber);
        if (!parcel) {
            return res.status(404).json({
                success: false,
                message: "Parcel tracking number not found",
            });
        }
        return res.status(200).json({
            success: true,
            data: parcel,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to track parcel",
        });
    }
};
exports.trackParcel = trackParcel;
const changeParcelStatus = async (req, res) => {
    try {
        const parcelId = String(req.params.id);
        const parcel = await (0, parcel_service_1.getParcelById)(parcelId);
        if (!parcel) {
            return res.status(404).json({
                success: false,
                message: "Parcel not found",
            });
        }
        if (req.user.role ===
            "AGENCY_STAFF") {
            const originMembership = await (0, parcel_service_1.getAgencyStaffMembership)(req.user.userId, parcel.originBranch
                .agencyId);
            const destinationMembership = await (0, parcel_service_1.getAgencyStaffMembership)(req.user.userId, parcel.destinationBranch
                .agencyId);
            if (!originMembership &&
                !destinationMembership) {
                return res.status(403).json({
                    success: false,
                    message: "You are not authorized to update this parcel",
                });
            }
        }
        const validatedData = parcel_schema_1.updateParcelStatusSchema.parse(req.body);
        const updatedParcel = await (0, parcel_service_1.updateParcelStatus)({
            parcelId,
            status: validatedData.status,
            location: validatedData.location,
            description: validatedData.description,
            updatedById: req.user.userId,
        });
        return res.status(200).json({
            success: true,
            message: "Parcel status updated successfully",
            data: updatedParcel,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message ||
                "Unable to update parcel status",
        });
    }
};
exports.changeParcelStatus = changeParcelStatus;
//# sourceMappingURL=parcel.controller.js.map