import prisma from "../lib/prisma";

const AGENCY_ID =
  "912184dc-5b52-4a80-b6bd-177fd01d56ea";

const ROUTE_ID =
  "af0f9f5e-cf2b-4463-9865-9232b61e5431";

const VEHICLE_ID =
  "b0f17ecc-335a-434f-a849-6ade7c56ff08";

const DEPARTURE_TIME =
  new Date("2026-10-10T07:00:00.000Z");

const ARRIVAL_TIME =
  new Date("2026-10-10T11:00:00.000Z");

const main = async () => {
  const existingTrip =
    await prisma.trip.findFirst({
      where: {
        agencyId: AGENCY_ID,
        routeId: ROUTE_ID,
        vehicleId: VEHICLE_ID,
        departureTime: DEPARTURE_TIME,
      },
    });

  if (existingTrip) {
    console.log(
      "Future test trip already exists:"
    );
    console.log(existingTrip);
    return;
  }

  const trip = await prisma.trip.create({
    data: {
      departureTime: DEPARTURE_TIME,
      arrivalTime: ARRIVAL_TIME,

      price: 5000,

      totalSeats: 30,
      availableSeats: 30,

      status: "SCHEDULED",

      agencyId: AGENCY_ID,
      routeId: ROUTE_ID,
      vehicleId: VEHICLE_ID,
    },
  });

  console.log(
    "Future test trip created successfully:"
  );

  console.log(trip);
};

main()
  .catch((error) => {
    console.error(
      "Unable to create future test trip:",
      error
    );

    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });