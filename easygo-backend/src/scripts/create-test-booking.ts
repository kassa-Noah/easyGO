import prisma from "../lib/prisma";

const CUSTOMER_EMAIL = "customer@easygo.com";

const TRIP_ID =
  "dc751d5e-d7cd-432b-8d9d-67bf108fda10";

const BOOKING_REFERENCE =
  "EASYGO-JOURNEY-TEST-001";

const main = async () => {
  const customer = await prisma.user.findUnique({
    where: {
      email: CUSTOMER_EMAIL,
    },
  });

  if (!customer) {
    throw new Error(
      `Customer ${CUSTOMER_EMAIL} was not found`
    );
  }

  if (customer.role !== "CUSTOMER") {
    throw new Error(
      `${CUSTOMER_EMAIL} is not a CUSTOMER`
    );
  }

  const trip = await prisma.trip.findUnique({
    where: {
      id: TRIP_ID,
    },
  });

  if (!trip) {
    throw new Error(
      `Trip ${TRIP_ID} was not found`
    );
  }

  const existingBooking =
    await prisma.booking.findUnique({
      where: {
        bookingReference: BOOKING_REFERENCE,
      },
    });

  if (existingBooking) {
    console.log("Test booking already exists:");
    console.log(existingBooking);
    return;
  }

  const tripAmount = Number(trip.price);

  const booking = await prisma.booking.create({
    data: {
      bookingReference: BOOKING_REFERENCE,

      numberOfSeats: 1,

      tripAmount,
      taxiPickupAmount: 0,
      taxiDropoffAmount: 0,

      totalAmount: tripAmount,

      status: "PENDING",

      userId: customer.id,
      tripId: trip.id,
    },
  });

  console.log("Test booking created successfully:");
  console.log(booking);
};

main()
  .catch((error) => {
    console.error(
      "Unable to create test booking:",
      error
    );

    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });