/**
 * Reconciles a trip's seat count against the bookings that hold seats.
 *
 * Written because a cleanup left the trip one seat shorter than it should have
 * been, and the only way to tell a leak from a mistake in the cleanup is to add
 * up what the bookings actually say.
 *
 * Run with: npx tsx src/scripts/report-trip-seats.ts <tripId>
 */
import prisma from "../lib/prisma";

async function main() {
  const tripId =
    process.argv[2] ??
    "7df477ba-ea73-4e41-887d-851c58a1874d";

  const trip = await prisma.trip.findUnique({
    where: { id: tripId },
    select: {
      id: true,
      status: true,
      totalSeats: true,
      availableSeats: true,
    },
  });

  if (!trip) {
    console.log(`No trip ${tripId}.`);

    return;
  }

  const bookings = await prisma.booking.findMany({
    where: { tripId },

    select: {
      id: true,
      bookingReference: true,
      numberOfSeats: true,
      status: true,
      createdAt: true,
      user: { select: { email: true } },
    },

    orderBy: { createdAt: "asc" },
  });

  console.log(
    `Trip ${trip.id}\n` +
      `  status ${trip.status}\n` +
      `  total ${trip.totalSeats}  available ${trip.availableSeats}\n` +
      `  held by the records below: ${trip.totalSeats - trip.availableSeats}\n`
  );

  const live = bookings.filter(
    (booking) => booking.status !== "CANCELLED"
  );

  let seats = 0;

  for (const booking of live) {
    seats += booking.numberOfSeats;

    console.log(
      `  ${booking.bookingReference}  ${booking.status}  ` +
        `${booking.numberOfSeats} seat(s)  ${booking.user.email}  ` +
        `${booking.createdAt.toISOString()}`
    );
  }

  const cancelled = bookings.length - live.length;

  console.log(
    `\n  live bookings: ${live.length} holding ${seats} seat(s)\n` +
      `  cancelled:     ${cancelled}\n` +
      `  expected available: ${trip.totalSeats - seats}\n` +
      `  actual available:   ${trip.availableSeats}\n` +
      (trip.totalSeats - seats === trip.availableSeats
        ? "  CONSISTENT"
        : "  *** MISMATCH ***")
  );
}

main()
  .catch((error) => {
    console.error("Unable to report on the trip:", error);

    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
