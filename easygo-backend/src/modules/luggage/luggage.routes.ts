import { Router } from "express";

import {
  changeLuggageStatus,
  getLuggage,
  listMyLuggage,
  registerLuggage,
  trackLuggage,
} from "./luggage.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router = Router();

router.post(
  "/",
  authenticate,
  authorizeRoles("CUSTOMER"),
  registerLuggage
);

router.get(
  "/me",
  authenticate,
  authorizeRoles("CUSTOMER"),
  listMyLuggage
);

router.get(
  "/track/:trackingNumber",
  authenticate,
  authorizeRoles("CUSTOMER"),
  trackLuggage
);

router.patch(
  "/:id/status",
  authenticate,
  authorizeRoles(
    "AGENCY_STAFF",
    "ADMIN"
  ),
  changeLuggageStatus
);

router.get(
  "/:id",
  authenticate,
  getLuggage
);

export default router;