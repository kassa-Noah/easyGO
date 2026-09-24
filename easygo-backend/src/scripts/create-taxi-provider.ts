import prisma from "../lib/prisma";

const PROVIDER_NAME = "easyGO Simulated Taxi Service";

const main = async () => {
  const existingProvider =
    await prisma.taxiProvider.findFirst({
      where: {
        name: PROVIDER_NAME,
      },
    });

  if (existingProvider) {
    console.log("Taxi provider already exists:");
    console.log(existingProvider);
    return;
  }

  const provider = await prisma.taxiProvider.create({
    data: {
      name: PROVIDER_NAME,
      type: "SIMULATED",
      isActive: true,
    },
  });

  console.log(
    "Simulated taxi provider created successfully:"
  );

  console.log(provider);
};

main()
  .catch((error) => {
    console.error(
      "Unable to create taxi provider:",
      error
    );

    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });