import { Router } from "express";

import { authenticate } from "../../middleware/auth.middleware";
import { authorizeRoles } from "../../middleware/role.middleware";

import {
  addTrip,
  editTrip,
  getTrip,
  listTrips,
} from "./trip.controller";

const router = Router();

// Public
router.get("/", listTrips);

router.get("/:id", getTrip);

// ADMIN or agency staff
router.post(
  "/",
  authenticate,
  authorizeRoles("ADMIN", "AGENCY_STAFF"),
  addTrip
);

router.patch(
  "/:id",
  authenticate,
  authorizeRoles("ADMIN", "AGENCY_STAFF"),
  editTrip
);

export default router;