import prisma from "./prisma";

/**
 * The active staff of an agency.
 *
 * An event that concerns an agency has to reach everyone who might act on it,
 * which is why this returns every member rather than one. It lives here rather
 * than in one of the modules that uses it, because more than one of them needs
 * it and an event is not owned by the feature that first wanted it.
 */
export const listAgencyStaffUserIds = async (agencyId: string) => {
  const staff = await prisma.agencyStaff.findMany({
    where: {
      agencyId,
      isActive: true,
    },

    select: {
      userId: true,
    },
  });

  return staff.map((member) => member.userId);
};

/**
 * Every administrator, so a platform-level event can reach them.
 *
 * Notifications are addressed to an account, not to a role, so an
 * administrator's bell only ever rings when a notification is written for them
 * by name.
 */
export const listAdminUserIds = async () => {
  const admins = await prisma.user.findMany({
    where: {
      role: "ADMIN",
      isActive: true,
    },

    select: {
      id: true,
    },
  });

  return admins.map((admin) => admin.id);
};
