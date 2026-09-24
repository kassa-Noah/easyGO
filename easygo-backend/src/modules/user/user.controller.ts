import { Request, Response } from "express";

import {
  getAllUsers,
  getCurrentUser,
  getUserById,
  updateCurrentUser,
  updateUserStatus,
} from "./user.service";

import {
  updateProfileSchema,
  updateUserStatusSchema,
} from "./user.schema";

export const getMe = async (req: Request, res: Response) => {
  try {
    const user = await getCurrentUser(req.user!.userId);

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
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: error.message || "Unable to retrieve user profile",
    });
  }
};

export const updateMe = async (req: Request, res: Response) => {
  try {
    const validatedData = updateProfileSchema.parse(req.body);

    const user = await updateCurrentUser(
      req.user!.userId,
      validatedData
    );

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      data: user,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: error.message || "Unable to update profile",
    });
  }
};

export const listUsers = async (
  _req: Request,
  res: Response
) => {
  try {
    const users = await getAllUsers();

    return res.status(200).json({
      success: true,
      data: users,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: error.message || "Unable to retrieve users",
    });
  }
};

export const getUser = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = String(req.params.id);

    const user = await getUserById(userId);

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
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: error.message || "Unable to retrieve user",
    });
  }
};

export const changeUserStatus = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = String(req.params.id);

    const validatedData = updateUserStatusSchema.parse(req.body);

    const user = await updateUserStatus(
      userId,
      validatedData.isActive
    );

    return res.status(200).json({
      success: true,
      message: "User status updated successfully",
      data: user,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: error.message || "Unable to update user status",
    });
  }
};