import { Request, Response } from "express";
import { messageOf } from "../../lib/error-message";
import { changePasswordSchema, loginSchema, registerSchema } from "./auth.schema";
import { loginUser, registerUser } from "./auth.service";
import { changePasswordForUser } from "./change-password.service";

export const register = async (req: Request, res: Response) => {
  try {
    const validatedData = registerSchema.parse(req.body);

    const result = await registerUser(validatedData);

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: messageOf(error) || "Registration failed",
    });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const validatedData = loginSchema.parse(req.body);

    const result = await loginUser(validatedData);

    res.status(200).json({
      success: true,
      message: "Login successful",
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: messageOf(error) || "Login failed",
    });
  }
};

/**
 * Changes the signed-in account's password.
 *
 * The account comes from the verified token, never from the request body, so a
 * caller cannot change someone else's password by naming them.
 */
export const changePassword = async (req: Request, res: Response) => {
  try {
    const validatedData = changePasswordSchema.parse(req.body);

    const result = await changePasswordForUser({
      userId: req.user!.userId,

      currentPassword: validatedData.currentPassword,

      newPassword: validatedData.newPassword,
    });

    res.status(200).json({
      success: true,
      message: "Password changed successfully",
      data: result,
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: messageOf(error) || "Unable to change the password",
    });
  }
};