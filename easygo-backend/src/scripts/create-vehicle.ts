import prisma from "../lib/prisma";

async function main() {
  // Remove the malformed test vehicle
  await prisma.vehicle.deleteMany({
    where: {
      registrationNumber: "LT-001-EG",
    },
  });

  console.log("Old malformed vehicle removed.");

  // Create a clean vehicle and allow Prisma to generate the UUID
  const vehicle = await prisma.vehicle.create({
    data: {
      registrationNumber: "LT-001-EG",
      brand: "Toyota",
      model: "Coaster",
      capacity: 30,
      isActive: true,
      agencyId: "912184dc-5b52-4a80-b6bd-177fd01d56ea",
    },
  });

  console.log("NEW VEHICLE ID =", vehicle.id);
  console.log("ID LENGTH =", vehicle.id.length);
  console.log(vehicle);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });