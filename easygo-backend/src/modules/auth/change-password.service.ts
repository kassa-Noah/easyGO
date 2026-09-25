import bcrypt from "bcryptjs";
import prisma from "../../lib/prisma";

interface ChangePasswordInput {
  userId: string;
  currentPassword: string;
  newPassword: string;
}

/**
 * Changes a password.
 *
 * The current password is required and verified, so a stolen token alone cannot
 * be used to lock the real owner out of their account. The new hash uses the
 * same cost as registration.
 *
 * The password history is deliberately not checked: the platform does not store
 * previous hashes, so it cannot claim to reject a reused password.
 */
export const changePasswordForUser = async (data: ChangePasswordInput) => {
  const user = await prisma.user.findUnique({
    where: {
      id: data.userId,
    },

    select: {
      id: true,
      email: true,
      passwordHash: true,
    },
  });

  if (!user) {
    throw new Error("User not found");
  }

  const currentMatches = await bcrypt.compare(
    data.currentPassword,
    user.passwordHash
  );

  if (!currentMatches) {
    throw new Error("Your current password is not correct");
  }

  if (data.currentPassword === data.newPassword) {
    throw new Error(
      "Your new password must be different from your current one"
    );
  }

  const passwordHash = await bcrypt.hash(data.newPassword, 12);

  await prisma.user.update({
    where: {
      id: data.userId,
    },

    data: {
      passwordHash,
    },
  });

  return {
    id: user.id,
    email: user.email,
  };
};
