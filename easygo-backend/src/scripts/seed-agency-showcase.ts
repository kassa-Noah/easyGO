import prisma from "../lib/prisma";

// Fills the platform with enough transport agencies for the customer home to
// have a showcase worth scrolling, with branches, routes and bookable trips so
// every agency on that showcase can actually be travelled with. An agency that
// cannot be booked is a dead end for the reader who taps it.
//
// The names are invented. They are deliberately not the names of real Cameroonian
// operators: seed data that borrows a real company's identity is confusing at
// best, and at worst it puts someone else's brand on a demonstration screen.
//
// The script is idempotent. An agency that already exists is left in place and
// only has its descriptive fields refreshed; branches, routes and trips are all
// matched before they are created, so running this twice does not duplicate
// anything.

interface SeedBranch {
  city: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
}

interface SeedRoute {
  from: string;
  to: string;
  distanceKm: number;
  minutes: number;
  fare: number;
}

interface SeedAgency {
  name: string;
  description: string;
  phone: string;
  email: string;
  website: string;
  branches: SeedBranch[];
  routes: SeedRoute[];
}

const SEED_AGENCIES: SeedAgency[] = [
  {
    name: "Cameroun Express",
    description: "Daily coastal departures between Douala and Yaounde.",
    phone: "699100201",
    email: "contact@camerounexpress.cm",
    website: "https://www.camerounexpress.cm",
    branches: [
      {
        city: "Douala",
        name: "Douala Bonaberi Terminal",
        address: "Bonaberi, Douala",
        latitude: 4.0689,
        longitude: 9.6796,
      },
      {
        city: "Yaounde",
        name: "Yaounde Nsam Terminal",
        address: "Nsam, Yaounde",
        latitude: 3.8288,
        longitude: 11.4926,
      },
    ],
    routes: [
      { from: "Douala", to: "Yaounde", distanceKm: 250, minutes: 240, fare: 5500 },
    ],
  },
  {
    name: "Nord Trans",
    description: "The northern corridor, every morning.",
    phone: "699100202",
    email: "contact@nordtrans.cm",
    website: "https://www.nordtrans.cm",
    branches: [
      {
        city: "Garoua",
        name: "Garoua Central Terminal",
        address: "Roumdé Adjia, Garoua",
        latitude: 9.3017,
        longitude: 13.3921,
      },
      {
        city: "Maroua",
        name: "Maroua Domayo Terminal",
        address: "Domayo, Maroua",
        latitude: 10.5910,
        longitude: 14.3158,
      },
    ],
    routes: [
      { from: "Garoua", to: "Maroua", distanceKm: 220, minutes: 210, fare: 5000 },
    ],
  },
  {
    name: "Buca Voyages",
    description: "South-west connections from the mountain to the sea.",
    phone: "699100203",
    email: "contact@bucavoyages.cm",
    website: "https://www.bucavoyages.cm",
    branches: [
      {
        city: "Buea",
        name: "Buea Mile 17 Terminal",
        address: "Mile 17, Buea",
        latitude: 4.1520,
        longitude: 9.2880,
      },
      {
        city: "Kumba",
        name: "Kumba Main Terminal",
        address: "Fiango, Kumba",
        latitude: 4.6363,
        longitude: 9.4469,
      },
      {
        city: "Limbe",
        name: "Limbe Down Beach Terminal",
        address: "Down Beach, Limbe",
        latitude: 4.0171,
        longitude: 9.2109,
      },
    ],
    routes: [
      { from: "Buea", to: "Kumba", distanceKm: 90, minutes: 120, fare: 2500 },
      { from: "Limbe", to: "Buea", distanceKm: 20, minutes: 35, fare: 800 },
    ],
  },
  {
    name: "Mont Cameroun Transport",
    description: "Highland routes across the West region.",
    phone: "699100204",
    email: "contact@montcamerountransport.cm",
    website: "https://www.montcamerountransport.cm",
    branches: [
      {
        city: "Bafoussam",
        name: "Bafoussam Banengo Terminal",
        address: "Banengo, Bafoussam",
        latitude: 5.4781,
        longitude: 10.4172,
      },
      {
        city: "Dschang",
        name: "Dschang Central Terminal",
        address: "Centre, Dschang",
        latitude: 5.4456,
        longitude: 10.0533,
      },
      {
        city: "Bamenda",
        name: "Bamenda Nkwen Terminal",
        address: "Nkwen, Bamenda",
        latitude: 5.9735,
        longitude: 10.1656,
      },
    ],
    routes: [
      { from: "Bafoussam", to: "Bamenda", distanceKm: 75, minutes: 100, fare: 2500 },
      { from: "Dschang", to: "Bafoussam", distanceKm: 55, minutes: 80, fare: 1500 },
    ],
  },
  {
    name: "Littoral Lines",
    description: "Coast and port services along the Littoral.",
    phone: "699100205",
    email: "contact@littorallines.cm",
    website: "https://www.littorallines.cm",
    branches: [
      {
        city: "Douala",
        name: "Douala Ndokotti Terminal",
        address: "Ndokotti, Douala",
        latitude: 4.0459,
        longitude: 9.7201,
      },
      {
        city: "Edea",
        name: "Edea Central Terminal",
        address: "Centre, Edea",
        latitude: 3.8000,
        longitude: 10.1333,
      },
      {
        city: "Kribi",
        name: "Kribi Mboa-Manga Terminal",
        address: "Mboa-Manga, Kribi",
        latitude: 2.9404,
        longitude: 9.9098,
      },
    ],
    routes: [
      { from: "Douala", to: "Kribi", distanceKm: 160, minutes: 180, fare: 3500 },
      { from: "Douala", to: "Edea", distanceKm: 60, minutes: 75, fare: 1500 },
    ],
  },
  {
    name: "Sahel Express",
    description: "Long-haul links to the Far North.",
    phone: "699100206",
    email: "contact@sahelexpress.cm",
    website: "https://www.sahelexpress.cm",
    branches: [
      {
        city: "Maroua",
        name: "Maroua Kakataré Terminal",
        address: "Kakataré, Maroua",
        latitude: 10.5956,
        longitude: 14.3247,
      },
      {
        city: "Ngaoundere",
        name: "Ngaoundere Baladji Terminal",
        address: "Baladji, Ngaoundéré",
        latitude: 7.3167,
        longitude: 13.5833,
      },
    ],
    routes: [
      { from: "Ngaoundere", to: "Maroua", distanceKm: 350, minutes: 330, fare: 8000 },
    ],
  },
  {
    name: "Centre Inter",
    description: "Forest and eastern corridor services.",
    phone: "699100207",
    email: "contact@centreinter.cm",
    website: "https://www.centreinter.cm",
    branches: [
      {
        city: "Yaounde",
        name: "Yaounde Mvan Terminal",
        address: "Mvan, Yaounde",
        latitude: 3.8224,
        longitude: 11.5366,
      },
      {
        city: "Bertoua",
        name: "Bertoua Central Terminal",
        address: "Centre, Bertoua",
        latitude: 4.5776,
        longitude: 13.6846,
      },
      {
        city: "Ebolowa",
        name: "Ebolowa Central Terminal",
        address: "Centre, Ebolowa",
        latitude: 2.9000,
        longitude: 11.1500,
      },
    ],
    routes: [
      { from: "Yaounde", to: "Bertoua", distanceKm: 350, minutes: 300, fare: 7000 },
      { from: "Yaounde", to: "Ebolowa", distanceKm: 155, minutes: 165, fare: 3000 },
    ],
  },
  {
    name: "Ouest Voyages",
    description: "West to Centre, and back the same day.",
    phone: "699100208",
    email: "contact@ouestvoyages.cm",
    website: "https://www.ouestvoyages.cm",
    branches: [
      {
        city: "Bafoussam",
        name: "Bafoussam Tamdja Terminal",
        address: "Tamdja, Bafoussam",
        latitude: 5.4862,
        longitude: 10.4035,
      },
      {
        city: "Bamenda",
        name: "Bamenda Mile 4 Terminal",
        address: "Mile 4, Bamenda",
        latitude: 5.9437,
        longitude: 10.1447,
      },
      {
        city: "Yaounde",
        name: "Yaounde Mimboman Terminal",
        address: "Mimboman, Yaounde",
        latitude: 3.8667,
        longitude: 11.5500,
      },
    ],
    routes: [
      { from: "Bamenda", to: "Yaounde", distanceKm: 370, minutes: 360, fare: 7500 },
      { from: "Bafoussam", to: "Yaounde", distanceKm: 290, minutes: 285, fare: 6000 },
    ],
  },
];

/// The departures created for every route. Fixed times rather than a random
/// spread, so the same route always shows the same timetable.
const DEPARTURES: { daysAhead: number; hour: number; minute: number }[] = [
  { daysAhead: 1, hour: 6, minute: 30 },
  { daysAhead: 2, hour: 15, minute: 0 },
  { daysAhead: 4, hour: 6, minute: 30 },
];

const SEATS = 70;

const departureFor = (
  daysAhead: number,
  hour: number,
  minute: number
): Date => {
  const date = new Date();

  date.setDate(date.getDate() + daysAhead);
  date.setHours(hour, minute, 0, 0);

  return date;
};

const seedAgency = async (seed: SeedAgency) => {
  const existing = await prisma.agency.findFirst({
    where: { name: seed.name },
  });

  const agency =
    existing ??
    (await prisma.agency.create({
      data: { name: seed.name },
    }));

  // Refreshed every run so the showcase copy can be reworded by editing this
  // file and running it again.
  await prisma.agency.update({
    where: { id: agency.id },
    data: {
      description: seed.description,
      phone: seed.phone,
      email: seed.email,
      website: seed.website,
      isActive: true,
    },
  });

  const branchIds = new Map<string, string>();

  for (const branch of seed.branches) {
    const found = await prisma.agencyBranch.findFirst({
      where: { agencyId: agency.id, name: branch.name },
    });

    const row =
      found ??
      (await prisma.agencyBranch.create({
        data: { ...branch, agencyId: agency.id },
      }));

    branchIds.set(branch.city, row.id);
  }

  let routes = 0;
  let trips = 0;

  for (const route of seed.routes) {
    const originBranchId = branchIds.get(route.from);
    const destinationBranchId = branchIds.get(route.to);

    if (!originBranchId || !destinationBranchId) {
      throw new Error(
        `Route ${route.from}->${route.to} on ${seed.name} names a city with no branch.`
      );
    }

    // The pair is unique in the schema, so upsert cannot duplicate a route.
    const row = await prisma.route.upsert({
      where: {
        originBranchId_destinationBranchId: {
          originBranchId,
          destinationBranchId,
        },
      },
      update: {
        distanceKm: route.distanceKm,
        estimatedDurationMinutes: route.minutes,
        baseFare: route.fare,
        isActive: true,
      },
      create: {
        originBranchId,
        destinationBranchId,
        distanceKm: route.distanceKm,
        estimatedDurationMinutes: route.minutes,
        baseFare: route.fare,
      },
    });

    routes += 1;

    for (const departure of DEPARTURES) {
      const departureTime = departureFor(
        departure.daysAhead,
        departure.hour,
        departure.minute
      );

      // No unique constraint on (route, departure time), so it is matched by
      // hand rather than upserted.
      const already = await prisma.trip.findFirst({
        where: { routeId: row.id, departureTime },
      });

      if (already) {
        continue;
      }

      const arrivalTime = new Date(
        departureTime.getTime() + route.minutes * 60 * 1000
      );

      await prisma.trip.create({
        data: {
          departureTime,
          arrivalTime,
          price: route.fare,
          totalSeats: SEATS,
          availableSeats: SEATS,
          status: "SCHEDULED",
          agencyId: agency.id,
          routeId: row.id,
        },
      });

      trips += 1;
    }
  }

  console.log(
    `  ${seed.name.padEnd(26)} branches=${seed.branches.length} routes=${routes} newTrips=${trips}`
  );
};

const main = async () => {
  console.log(`Seeding ${SEED_AGENCIES.length} agencies ...`);

  for (const seed of SEED_AGENCIES) {
    await seedAgency(seed);
  }

  const agencies = await prisma.agency.count();
  const routes = await prisma.route.count();
  const trips = await prisma.trip.count();

  console.log(
    `Done. The database now holds ${agencies} agencies, ${routes} routes and ${trips} trips.`
  );
};

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);

    await prisma.$disconnect();

    process.exit(1);
  });
