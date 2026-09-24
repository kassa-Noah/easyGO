import { z } from "zod";

export const createAgencySchema = z.object({
  name: z.string().min(2, "Agency name is required"),
  description: z.string().optional(),
  email: z.string().email("Invalid email").optional(),
  phone: z.string().min(8, "Invalid phone number").optional(),
  logoUrl: z.string().url("Invalid logo URL").optional(),
});

export const updateAgencySchema = z.object({
  name: z.string().min(2).optional(),
  description: z.string().optional(),
  email: z.string().email().optional(),
  phone: z.string().min(8).optional(),
  logoUrl: z.string().url().optional(),
  isActive: z.boolean().optional(),
});

export const createBranchSchema = z.object({
  name: z.string().min(2, "Branch name is required"),
  city: z.string().min(2, "City is required"),
  address: z.string().min(2, "Address is required"),
  latitude: z.number(),
  longitude: z.number(),
  phone: z.string().min(8).optional(),
});

export const updateBranchSchema = z.object({
  name: z.string().min(2).optional(),
  city: z.string().min(2).optional(),
  address: z.string().min(2).optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  phone: z.string().min(8).optional(),
});