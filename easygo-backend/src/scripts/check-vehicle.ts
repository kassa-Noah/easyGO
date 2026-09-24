import prisma from "../lib/prisma";

async function main() {
  const vehicle = await prisma.vehicle.findUnique({
    where: {
      registrationNumber: "LT-001-EG",
    },
  });

  if (!vehicle) {
    console.log("Vehicle not found");
    return;
  }

  console.log("VEHICLE ID =", vehicle.id);
  console.log("ID LENGTH =", vehicle.id.length);
  console.log(vehicle);
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
  });