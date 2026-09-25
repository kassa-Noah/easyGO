import prisma from "../lib/prisma";

const main = async () => {
  const users = await prisma.user.findMany({
    orderBy: { createdAt: "asc" },
    select: {
      email: true,
      phone: true,
      role: true,
      firstName: true,
      lastName: true,
      agencyStaff: {
        select: {
          role: true,
          agency: { select: { name: true } },
        },
      },
    },
  });

  console.log(`Total users: ${users.length}`);
  console.log("");

  for (const user of users) {
    const staff = user.agencyStaff
      ? ` | staff:${user.agencyStaff.role}@${user.agencyStaff.agency.name}`
      : "";

    console.log(
      `${user.role.padEnd(13)} ${user.email.padEnd(30)} ${user.phone}${staff}`
    );
  }

  const providers = await prisma.taxiProvider.findMany();

  console.log("");
  console.log(`Taxi providers: ${providers.length}`);

  for (const provider of providers) {
    console.log(`  ${provider.name} (${provider.type})`);
  }
};

main()
  .catch((error) => {
    console.error("Unable to list users:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
