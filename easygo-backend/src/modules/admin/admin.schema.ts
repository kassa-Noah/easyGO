import { z } from "zod";

/**
 * Attaches an existing account to an agency as a member of its staff.
 *
 * The role here is the agency-side role (MANAGER or AGENT), not the platform
 * role. Attaching also promotes the account's platform role to AGENCY_STAFF,
 * because every agency-console endpoint is gated on that role.
 */
export const attachStaffSchema = z.object({
  userId: z.string().uuid("Invalid user ID"),

  role: z
    .enum(["MANAGER", "AGENT"], {
      error: "A staff role must be MANAGER or AGENT",
    })
    .optional(),
});
