"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.editBranch = exports.addBranch = exports.listBranches = exports.editAgency = exports.addAgency = exports.getAgency = exports.listAgencies = void 0;
const agency_service_1 = require("./agency.service");
const agency_schema_1 = require("./agency.schema");
const canManageAgency = async (userId, role, agencyId) => {
    if (role === "ADMIN") {
        return true;
    }
    if (role !== "AGENCY_STAFF") {
        return false;
    }
    const membership = await (0, agency_service_1.getAgencyStaffMembership)(userId, agencyId);
    if (!membership) {
        return false;
    }
    return membership.role === "MANAGER";
};
const listAgencies = async (_req, res) => {
    try {
        const agencies = await (0, agency_service_1.getAllAgencies)();
        return res.status(200).json({
            success: true,
            data: agencies,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve agencies",
        });
    }
};
exports.listAgencies = listAgencies;
const getAgency = async (req, res) => {
    try {
        const agency = await (0, agency_service_1.getAgencyById)(req.params.id);
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
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve agency",
        });
    }
};
exports.getAgency = getAgency;
const addAgency = async (req, res) => {
    try {
        const validatedData = agency_schema_1.createAgencySchema.parse(req.body);
        const agency = await (0, agency_service_1.createAgency)(validatedData);
        return res.status(201).json({
            success: true,
            message: "Agency created successfully",
            data: agency,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to create agency",
        });
    }
};
exports.addAgency = addAgency;
const editAgency = async (req, res) => {
    try {
        const allowed = await canManageAgency(req.user.userId, req.user.role, req.params.id);
        if (!allowed) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to manage this agency",
            });
        }
        const validatedData = agency_schema_1.updateAgencySchema.parse(req.body);
        const agency = await (0, agency_service_1.updateAgency)(req.params.id, validatedData);
        return res.status(200).json({
            success: true,
            message: "Agency updated successfully",
            data: agency,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to update agency",
        });
    }
};
exports.editAgency = editAgency;
const listBranches = async (req, res) => {
    try {
        const agency = await (0, agency_service_1.getAgencyById)(req.params.id);
        if (!agency) {
            return res.status(404).json({
                success: false,
                message: "Agency not found",
            });
        }
        const branches = await (0, agency_service_1.getAgencyBranches)(req.params.id);
        return res.status(200).json({
            success: true,
            data: branches,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve branches",
        });
    }
};
exports.listBranches = listBranches;
const addBranch = async (req, res) => {
    try {
        const allowed = await canManageAgency(req.user.userId, req.user.role, req.params.id);
        if (!allowed) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to manage this agency",
            });
        }
        const validatedData = agency_schema_1.createBranchSchema.parse(req.body);
        const branch = await (0, agency_service_1.createAgencyBranch)(req.params.id, validatedData);
        return res.status(201).json({
            success: true,
            message: "Agency branch created successfully",
            data: branch,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to create branch",
        });
    }
};
exports.addBranch = addBranch;
const editBranch = async (req, res) => {
    try {
        const branch = await (0, agency_service_1.getBranchById)(req.params.branchId);
        if (!branch) {
            return res.status(404).json({
                success: false,
                message: "Branch not found",
            });
        }
        if (branch.agencyId !== req.params.id) {
            return res.status(400).json({
                success: false,
                message: "Branch does not belong to this agency",
            });
        }
        const allowed = await canManageAgency(req.user.userId, req.user.role, req.params.id);
        if (!allowed) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to manage this agency",
            });
        }
        const validatedData = agency_schema_1.updateBranchSchema.parse(req.body);
        const updatedBranch = await (0, agency_service_1.updateAgencyBranch)(req.params.branchId, validatedData);
        return res.status(200).json({
            success: true,
            message: "Agency branch updated successfully",
            data: updatedBranch,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to update branch",
        });
    }
};
exports.editBranch = editBranch;
//# sourceMappingURL=agency.controller.js.map