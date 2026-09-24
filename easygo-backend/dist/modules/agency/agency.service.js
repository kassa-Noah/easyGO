"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBranchById = exports.getAgencyStaffMembership = exports.updateAgencyBranch = exports.createAgencyBranch = exports.getAgencyBranches = exports.updateAgency = exports.createAgency = exports.getAgencyById = exports.getAllAgencies = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getAllAgencies = async () => {
    return prisma_1.default.agency.findMany({
        where: {
            isActive: true,
        },
        include: {
            branches: true,
        },
        orderBy: {
            name: "asc",
        },
    });
};
exports.getAllAgencies = getAllAgencies;
const getAgencyById = async (agencyId) => {
    return prisma_1.default.agency.findUnique({
        where: {
            id: agencyId,
        },
        include: {
            branches: true,
        },
    });
};
exports.getAgencyById = getAgencyById;
const createAgency = async (data) => {
    return prisma_1.default.agency.create({
        data,
    });
};
exports.createAgency = createAgency;
const updateAgency = async (agencyId, data) => {
    return prisma_1.default.agency.update({
        where: {
            id: agencyId,
        },
        data,
    });
};
exports.updateAgency = updateAgency;
const getAgencyBranches = async (agencyId) => {
    return prisma_1.default.agencyBranch.findMany({
        where: {
            agencyId,
        },
        orderBy: {
            city: "asc",
        },
    });
};
exports.getAgencyBranches = getAgencyBranches;
const createAgencyBranch = async (agencyId, data) => {
    return prisma_1.default.agencyBranch.create({
        data: {
            agencyId,
            ...data,
        },
    });
};
exports.createAgencyBranch = createAgencyBranch;
const updateAgencyBranch = async (branchId, data) => {
    return prisma_1.default.agencyBranch.update({
        where: {
            id: branchId,
        },
        data,
    });
};
exports.updateAgencyBranch = updateAgencyBranch;
const getAgencyStaffMembership = async (userId, agencyId) => {
    return prisma_1.default.agencyStaff.findFirst({
        where: {
            userId,
            agencyId,
        },
    });
};
exports.getAgencyStaffMembership = getAgencyStaffMembership;
const getBranchById = async (branchId) => {
    return prisma_1.default.agencyBranch.findUnique({
        where: {
            id: branchId,
        },
    });
};
exports.getBranchById = getBranchById;
//# sourceMappingURL=agency.service.js.map