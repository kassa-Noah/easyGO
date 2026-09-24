import { Router } from "express";

import {
  addJourney,
  changeJourneyStatus,
  getJourney,
  listMyJourneys,
} from "./journey.controller";

import { authenticate } from "../../middleware/auth.middleware";
import { authorizeRoles } from "../../middleware/role.middleware";

const router = Router();

// Customer creates a door-to-door journey
// for one of their bookings.
router.post(
  "/",
  authenticate,
  authorizeRoles("CUSTOMER"),
  addJourney
);

// Customer retrieves all their own journeys.
router.get(
  "/me",
  authenticate,
  authorizeRoles("CUSTOMER"),
  listMyJourneys
);

// Authenticated users can retrieve a journey.
// The controller protects customer ownership.
router.get(
  "/:id",
  authenticate,
  getJourney
);

// Journey status is controlled by operational
// actors, not by customers.
router.patch(
  "/:id/status",
  authenticate,
  authorizeRoles("ADMIN", "AGENCY_STAFF"),
  changeJourneyStatus
);

export default router;