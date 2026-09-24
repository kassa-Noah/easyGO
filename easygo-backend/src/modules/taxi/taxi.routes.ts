import { Router } from "express";

import {
  assignTaxi,
  changeTaxiAssignment,
  getTaxiAssignment,
  listJourneyTaxiAssignments,
} from "./taxi.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router = Router();

// Operational actor assigns a taxi
// to one segment of a journey.
router.post(
  "/journeys/:journeyId/assignments",
  authenticate,
  authorizeRoles(
    "ADMIN",
    "AGENCY_STAFF"
  ),
  assignTaxi
);

// Customer, agency staff or admin can
// retrieve the assignments of a journey.
// Ownership/agency authorization is checked
// by the controller.
router.get(
  "/journeys/:journeyId/assignments",
  authenticate,
  listJourneyTaxiAssignments
);

// Retrieve one taxi assignment.
router.get(
  "/assignments/:id",
  authenticate,
  getTaxiAssignment
);

// Operational actors update driver,
// vehicle, fare and assignment status.
router.patch(
  "/assignments/:id",
  authenticate,
  authorizeRoles(
    "ADMIN",
    "AGENCY_STAFF"
  ),
  changeTaxiAssignment
);

export default router;