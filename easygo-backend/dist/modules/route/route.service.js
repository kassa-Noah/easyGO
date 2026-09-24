"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBranchById = exports.updateRoute = exports.createRoute = exports.findExistingRoute = exports.getRouteById = exports.getAllRoutes = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getAllRoutes = async () => {
    return prisma_1.default.route.findMany({
        where: {
            isActive: true,
        },
        include: {
            originBranch: {
                include: {
                    agency: true,
                },
            },
            destinationBranch: {
                include: {
                    agency: true,
                },
            },
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getAllRoutes = getAllRoutes;
const getRouteById = async (routeId) => {
    return prisma_1.default.route.findUnique({
        where: {
            id: routeId,
        },
        include: {
            originBranch: {
                include: {
                    agency: true,
                },
            },
            destinationBranch: {
                include: {
                    agency: true,
                },
            },
        },
    });
};
exports.getRouteById = getRouteById;
const findExistingRoute = async (originBranchId, destinationBranchId) => {
    return prisma_1.default.route.findFirst({
        where: {
            originBranchId,
            destinationBranchId,
        },
    });
};
exports.findExistingRoute = findExistingRoute;
const createRoute = async (data) => {
    return prisma_1.default.route.create({
        data,
        include: {
            originBranch: true,
            destinationBranch: true,
        },
    });
};
exports.createRoute = createRoute;
const updateRoute = async (routeId, data) => {
    return prisma_1.default.route.update({
        where: {
            id: routeId,
        },
        data,
        include: {
            originBranch: true,
            destinationBranch: true,
        },
    });
};
exports.updateRoute = updateRoute;
const getBranchById = async (branchId) => {
    return prisma_1.default.agencyBranch.findUnique({
        where: {
            id: branchId,
        },
    });
};
exports.getBranchById = getBranchById;
//# sourceMappingURL=route.service.js.map