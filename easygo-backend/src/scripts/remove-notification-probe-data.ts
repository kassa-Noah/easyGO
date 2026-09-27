/**
 * Removes the records created while checking that a notification can be opened.
 *
 * The checks needed a real booking, a real message and the notifications each
 * one produced, because the thing being verified was whether the reference
 * fields are written — which no unit test can see. This puts the database back
 * where it was.
 *
 * Run with: npx tsx src/scripts/remove-notification-probe-data.ts
 */
import prisma from "../lib/prisma";

/// The booking created through the API while checking the booking notification.
const PROBE_BOOKING_REFERENCE = "EG-MUK0OIRN-LV1RCU";

/// The message posted as the agency while checking the message notification.
const PROBE_MESSAGE_BODY =
  "Your bus leaves from Mvog-Mbi at 07:00. Please arrive 20 minutes early.";

async function main() {
  const booking = await prisma.booking.findFirst({
    where: { bookingReference: PROBE_BOOKING_REFERENCE },
    select: {
      id: true,
      numberOfSeats: true,
      tripId: true,
      bookingReference: true,
    },
  });

  if (!booking) {
    console.log(
      `No booking ${PROBE_BOOKING_REFERENCE} to remove.`
    );
  } else {
    // Children first: the notifications and any ticket point at the booking.
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

    // The seat the probe booking held is given back, so the trip is left with
    // the availability it had before.
    await prisma.trip.update({
      where: { id: booking.tripId },
      data: {
        availableSeats: { increment: booking.numberOfSeats },
      },
    });

    console.log(
      `Removed booking ${booking.bookingReference}, ` +
        `${tickets.count} ticket(s) and ${notifications.count} ` +
        `notification(s); returned ${booking.numberOfSeats} seat(s).`
    );
  }

  const probeMessages = await prisma.message.deleteMany({
    where: { body: PROBE_MESSAGE_BODY },
  });

  console.log(`Removed ${probeMessages.count} probe message(s).`);

  // Every notification this check produced carried a reference, which is what
  // the probe was for; none of them existed before it.
  const probeNotifications = await prisma.notification.deleteMany({
    where: {
      referenceId: { not: null },
    },
  });

  console.log(
    `Removed ${probeNotifications.count} notification(s) carrying a reference.`
  );
}

main()
  .catch((error) => {
    console.error("Unable to remove the probe data:", error);

    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
