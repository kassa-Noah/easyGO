"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.changeUserStatus = exports.getUser = exports.listUsers = exports.updateMe = exports.getMe = void 0;
const user_service_1 = require("./user.service");
const user_schema_1 = require("./user.schema");
const getMe = async (req, res) => {
    try {
        const user = await (0, user_service_1.getCurrentUser)(req.user.userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found",
            });
        }
        return res.status(200).json({
            success: true,
            data: user,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve user profile",
        });
    }
};
exports.getMe = getMe;
const updateMe = async (req, res) => {
    try {
        const validatedData = user_schema_1.updateProfileSchema.parse(req.body);
        const user = await (0, user_service_1.updateCurrentUser)(req.user.userId, validatedData);
        return res.status(200).json({
            success: true,
            message: "Profile updated successfully",
            data: user,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to update profile",
        });
    }
};
exports.updateMe = updateMe;
const listUsers = async (_req, res) => {
    try {
        const users = await (0, user_service_1.getAllUsers)();
        return res.status(200).json({
            success: true,
            data: users,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve users",
        });
    }
};
exports.listUsers = listUsers;
const getUser = async (req, res) => {
    try {
        const user = await (0, user_service_1.getUserById)(req.params.id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found",
            });
        }
        return res.status(200).json({
            success: true,
            data: user,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve user",
        });
    }
};
exports.getUser = getUser;
const changeUserStatus = async (req, res) => {
    try {
        const validatedData = user_schema_1.updateUserStatusSchema.parse(req.body);
        const user = await (0, user_service_1.updateUserStatus)(req.params.id, validatedData.isActive);
        return res.status(200).json({
            success: true,
            message: "User status updated successfully",
            data: user,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to update user status",
        });
    }
};
exports.changeUserStatus = changeUserStatus;
//# sourceMappingURL=user.controller.js.map