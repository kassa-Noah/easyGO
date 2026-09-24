import { Router } from "express";

import { authenticate } from "../../middleware/auth.middleware";
import { authorizeRoles } from "../../middleware/role.middleware";

import {
  addAgency,
  addBranch,
  editAgency,
  editBranch,
  getAgency,
  listAgencies,
  listBranches,
} from "./agency.controller";

const router = Router();

// Public routes
router.get("/", listAgencies);

router.get("/:id", getAgency);

router.get("/:id/branches", listBranches);

// Admin only
router.post(
  "/",
  authenticate,
  authorizeRoles("ADMIN"),
  addAgency
);

// ADMIN or AGENCY_STAFF
router.patch(
  "/:id",
  authenticate,
  authorizeRoles("ADMIN", "AGENCY_STAFF"),
  editAgency
);

router.post(
  "/:id/branches",
  authenticate,
  authorizeRoles("ADMIN", "AGENCY_STAFF"),
  addBranch
);

router.patch(
  "/:id/branches/:branchId",
  authenticate,
  authorizeRoles("ADMIN", "AGENCY_STAFF"),
  editBranch
);

export default router;