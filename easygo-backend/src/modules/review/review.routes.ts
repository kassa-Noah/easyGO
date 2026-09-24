import { Router } from "express";

import {
  addReview,
  editReview,
  listAgencyReviews,
  listMyReviews,
  removeReview,
} from "./review.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router = Router();

router.get(
  "/agency/:agencyId",
  listAgencyReviews
);

router.post(
  "/",
  authenticate,
  authorizeRoles("CUSTOMER"),
  addReview
);

router.get(
  "/me",
  authenticate,
  authorizeRoles("CUSTOMER"),
  listMyReviews
);

router.patch(
  "/:id",
  authenticate,
  authorizeRoles("CUSTOMER"),
  editReview
);

router.delete(
  "/:id",
  authenticate,
  authorizeRoles("CUSTOMER"),
  removeReview
);

export default router;