import prisma from "../lib/prisma";

/**
 * Repairs trips whose seat accounting is internally inconsistent.
 *
 * `availableSeats` is the number of seats left to sell, so it can never exceed
 * `totalSeats`. Rows written before the capacity change in `updateTrip` adjusted
 * `availableSeats` started reading as a negative number of booked seats, because
 * the agency console derives booked seats as `totalSeats - availableSeats`.
 *
 * Only structurally impossible rows are touched: a trip where the two counts are
 * already consistent is left exactly as it is.
 */
const repairTripSeatAccounting = async () => {
  const trips = await prisma.trip.findMany({
    select: {
      id: true,
      totalSeats: true,
      availableSeats: true,
      route: {
        select: {
          originBranch: { select: { city: true } },
          destinationBranch: { select: { city: true } },
        },
      },
    },
  });

  const broken = trips.filter(
    (trip) => trip.availableSeats > trip.totalSeats
  );

  if (broken.length === 0) {
    console.log("No trips need repairing.");
    return;
  }

  for (const trip of broken) {
    console.log(
      `${trip.route.originBranch.city} -> ${trip.route.destinationBranch.city} ` +
        `(${trip.id}): availableSeats ${trip.availableSeats} > totalSeats ` +
        `${trip.totalSeats}, clamping to ${trip.totalSeats}`
    );

    await prisma.trip.update({
      where: { id: trip.id },
      data: { availableSeats: trip.totalSeats },
    });
  }

  console.log(`Repaired ${broken.length} trip(s).`);
};

repairTripSeatAccounting()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
