import { Router } from "express";

import {
  getDashboard,
  getMyAgency,
  listBookings,
  listLuggage,
  listParcels,
  listTrips,
} from "./staff.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router = Router();

// The whole console is reserved for agency staff. The agency itself
// is resolved from the staff membership in every controller.
router.use(
  authenticate,
  authorizeRoles("AGENCY_STAFF")
);

router.get("/agency", getMyAgency);

router.get("/dashboard", getDashboard);

router.get("/trips", listTrips);

router.get("/bookings", listBookings);

router.get("/luggage", listLuggage);

router.get("/parcels", listParcels);

export default router;
