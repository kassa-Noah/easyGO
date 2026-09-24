"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateUserStatus = exports.getUserById = exports.getAllUsers = exports.updateCurrentUser = exports.getCurrentUser = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getCurrentUser = async (userId) => {
    return prisma_1.default.user.findUnique({
        where: {
            id: userId,
        },
        select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            role: true,
            isActive: true,
            createdAt: true,
            updatedAt: true,
        },
    });
};
exports.getCurrentUser = getCurrentUser;
const updateCurrentUser = async (userId, data) => {
    if (data.phone) {
        const existingPhone = await prisma_1.default.user.findUnique({
            where: {
                phone: data.phone,
            },
        });
        if (existingPhone && existingPhone.id !== userId) {
            throw new Error("Phone number is already registered");
        }
    }
    return prisma_1.default.user.update({
        where: {
            id: userId,
        },
        data,
        select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            role: true,
            isActive: true,
            createdAt: true,
            updatedAt: true,
        },
    });
};
exports.updateCurrentUser = updateCurrentUser;
const getAllUsers = async () => {
    return prisma_1.default.user.findMany({
        select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            role: true,
            isActive: true,
            createdAt: true,
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getAllUsers = getAllUsers;
const getUserById = async (id) => {
    return prisma_1.default.user.findUnique({
        where: {
            id,
        },
        select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            role: true,
            isActive: true,
            createdAt: true,
            updatedAt: true,
        },
    });
};
exports.getUserById = getUserById;
const updateUserStatus = async (id, isActive) => {
    return prisma_1.default.user.update({
        where: {
            id,
        },
        data: {
            isActive,
        },
        select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            role: true,
            isActive: true,
        },
    });
};
exports.updateUserStatus = updateUserStatus;
//# sourceMappingURL=user.service.js.map