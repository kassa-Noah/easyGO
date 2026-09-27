/**
 * Removes the records created while checking that a device can be registered and
 * that push being switched off does not break a notification.
 *
 * The checks needed a real booking, a real notification and a real device token,
 * because the properties being verified — that the write still happens, that the
 * release is scoped to one account, that re-registering moves rather than
 * duplicates — are all about what reaches the database. No unit test can see
 * them.
 *
 * Run with: npx tsx src/scripts/remove-push-probe-data.ts
 */
import prisma from "../lib/prisma";

/// The bookings created through the API while checking that a broken push
/// credential or a switched-off one leaves the notification path working.
const PROBE_BOOKING_REFERENCES = [
  "EG-MUK5SVZQ-PJWEKR",
  "EG-MUK68EF1-BVBQI6",
  "EG-MUK69CXV-8YXS24",
];

/// The token used to check registration, releasing and cross-account guarding.
/// It is not a real Firebase token, which is the point: nothing was ever sent.
const PROBE_TOKEN_PREFIX = "fake-token-probe";

async function main() {
  for (const reference of PROBE_BOOKING_REFERENCES) {
    await removeProbeBooking(reference);
  }

  await removeProbeDevices();
}

async function removeProbeBooking(reference: string) {
  const booking = await prisma.booking.findFirst({
    where: { bookingReference: reference },

    select: {
      id: true,
      numberOfSeats: true,
      tripId: true,
      bookingReference: true,
    },
  });

  if (!booking) {
    console.log(`No booking ${reference} to remove.`);

    return;
  }

  const notifications = await prisma.notification.deleteMany({
    where: {
      referenceType: "BOOKING",
      referenceId: booking.id,
    },
  });

  const tickets = await prisma.ticket.deleteMany({
    where: { bookingId: booking.id },
  });

  await prisma.booking.delete({
    where: { id: booking.id },
  });

  // The seat the probe booking held goes back, so the trip is left as it was.
  await prisma.trip.update({
    where: { id: booking.tripId },
    data: {
      availableSeats: { increment: booking.numberOfSeats },
    },
  });

  console.log(
    `Removed booking ${booking.bookingReference}, ${tickets.count} ticket(s) ` +
      `and ${notifications.count} notification(s); ` +
      `returned ${booking.numberOfSeats} seat(s).`
  );
}

async function removeProbeDevices() {
  const devices = await prisma.deviceToken.deleteMany({
    where: {
      token: { startsWith: PROBE_TOKEN_PREFIX },
    },
  });

  console.log(`Removed ${devices.count} probe device token(s).`);
}

main()
  .catch((error) => {
    console.error("Unable to remove the probe data:", error);

    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
