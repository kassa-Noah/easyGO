import {
  Router,
} from "express";

import {
  dashboard,
  dashboardStatistics,
  listAllAgencies,
  listAllBookings,
  listAllLuggage,
  listAllParcels,
  listAllPayments,
} from "./admin.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router = Router();

router.use(
  authenticate,
  authorizeRoles("ADMIN")
);

router.get(
  "/dashboard",
  dashboard
);

router.get(
  "/statistics",
  dashboardStatistics
);

router.get(
  "/bookings",
  listAllBookings
);

router.get(
  "/agencies",
  listAllAgencies
);

router.get(
  "/payments",
  listAllPayments
);

router.get(
  "/parcels",
  listAllParcels
);

router.get(
  "/luggage",
  listAllLuggage
);

export default router;