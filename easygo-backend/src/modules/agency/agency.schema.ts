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

// A bare z.number() accepts a coordinate that cannot exist on Earth, and the
// API stored one during testing: latitude 200, longitude 500. The ranges are
// enforced here so a branch always sits somewhere real.
const latitudeSchema = z
  .number()
  .min(-90, "Latitude must be between -90 and 90")
  .max(90, "Latitude must be between -90 and 90");

const longitudeSchema = z
  .number()
  .min(-180, "Longitude must be between -180 and 180")
  .max(180, "Longitude must be between -180 and 180");

export const createBranchSchema = z.object({
  name: z.string().min(2, "Branch name is required"),
  city: z.string().min(2, "City is required"),
  address: z.string().min(2, "Address is required"),
  latitude: latitudeSchema,
  longitude: longitudeSchema,
  phone: z
    .string()
    .min(8, "A phone number needs at least 8 characters")
    .optional(),
});

export const updateBranchSchema = z.object({
  name: z.string().min(2).optional(),
  city: z.string().min(2).optional(),
  address: z.string().min(2).optional(),
  latitude: latitudeSchema.optional(),
  longitude: longitudeSchema.optional(),
  phone: z
    .string()
    .min(8, "A phone number needs at least 8 characters")
    .optional(),
});