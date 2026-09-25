import bcrypt from "bcryptjs";

import prisma from "../lib/prisma";

// Prepares one working demonstration account per role so that the
// customer, agency and administrator areas can all be demonstrated
// with known credentials.
//
// The script is idempotent. It creates an account when the email is
// missing, and otherwise resets the password and role so the
// documented credentials always work.
//
// Only the three easyGO demonstration accounts are touched. Real or
// personal accounts are never modified.

const AGENCY_NAME = "Finexs Voyages";

interface DemoAccount {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  password: string;
  role: "CUSTOMER" | "AGENCY_STAFF" | "ADMIN";
  linkToAgency: boolean;
}

const DEMO_ACCOUNTS: DemoAccount[] = [
  {
    firstName: "Claire",
    lastName: "Client",
    email: "customer@easygo.com",
    phone: "690000003",
    password: "Client1234",
    role: "CUSTOMER",
    linkToAgency: false,
  },
  {
    firstName: "Aline",
    lastName: "Agent",
    email: "manager@easygo.com",
    phone: "690000002",
    password: "Agency1234",
    role: "AGENCY_STAFF",
    linkToAgency: true,
  },
  {
    firstName: "Admin",
    lastName: "easyGO",
    email: "test@easygo.com",
    phone: "690000001",
    password: "Admin1234",
    role: "ADMIN",
    linkToAgency: false,
  },
];

const main = async () => {
  const agency = await prisma.agency.findFirst({
    where: {
      name: AGENCY_NAME,
    },
  });

  if (!agency) {
    throw new Error(
      `Agency "${AGENCY_NAME}" was not found. Seed the agency first.`
    );
  }

  for (const account of DEMO_ACCOUNTS) {
    const passwordHash = await bcrypt.hash(
      account.password,
      12
    );

    const existing = await prisma.user.findUnique({
      where: {
        email: account.email,
      },
    });

    let user;

    if (existing) {
      user = await prisma.user.update({
        where: {
          id: existing.id,
        },

        data: {
          firstName: account.firstName,
          lastName: account.lastName,
          passwordHash,
          role: account.role,
          isActive: true,
        },
      });

      console.log(
        `Updated: ${user.email} -> ${user.role} (password reset)`
      );
    } else {
      user = await prisma.user.create({
        data: {
          firstName: account.firstName,
          lastName: account.lastName,
          email: account.email,
          phone: account.phone,
          passwordHash,
          role: account.role,
        },
      });

      console.log(
        `Created: ${user.email} -> ${user.role}`
      );
    }

    // Agency staff must belong to an agency to reach its records.
    if (account.linkToAgency) {
      const membership =
        await prisma.agencyStaff.findFirst({
          where: {
            userId: user.id,
          },
        });

      if (membership) {
        await prisma.agencyStaff.update({
          where: {
            id: membership.id,
          },

          data: {
            agencyId: agency.id,
            role: "MANAGER",
            isActive: true,
          },
        });

        console.log(
          `Membership kept: ${user.email} in ${agency.name}`
        );
      } else {
        await prisma.agencyStaff.create({
          data: {
            userId: user.id,
            agencyId: agency.id,
            role: "MANAGER",
          },
        });

        console.log(
          `Linked: ${user.email} to ${agency.name} as MANAGER`
        );
      }
    }
  }

  console.log("");
  console.log("easyGO demonstration accounts");
  console.log("=============================");

  for (const account of DEMO_ACCOUNTS) {
    console.log(
      `${account.role.padEnd(13)} ${account.email.padEnd(24)} ${account.password}`
    );
  }
};

main()
  .catch((error) => {
    console.error(
      "Unable to prepare demonstration accounts:",
      error
    );

    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
