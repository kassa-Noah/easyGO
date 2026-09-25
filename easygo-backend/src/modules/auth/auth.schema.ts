import { z } from "zod";

export const registerSchema = z.object({
  firstName: z.string().min(2, "First name is required"),
  lastName: z.string().min(2, "Last name is required"),
  email: z.string().email("Invalid email address"),
  phone: z.string().min(8, "Invalid phone number"),
  password: z.string().min(6, "Password must contain at least 6 characters"),
});

export const loginSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(1, "Password is required"),
});

export const changePasswordSchema = z.object({
  currentPassword: z
    .string()
    .min(1, "Your current password is required"),

  newPassword: z
    .string()
    .min(6, "The new password must contain at least 6 characters")
    .max(72, "The new password is too long"),
});