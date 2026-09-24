import { Router } from "express";

import { authenticate } from "../../middleware/auth.middleware";
import { authorizeRoles } from "../../middleware/role.middleware";

import {
  addRoute,
  editRoute,
  getRoute,
  listRoutes,
} from "./route.controller";

const router = Router();

// Public
router.get("/", listRoutes);
router.get("/:id", getRoute);

// Admin only
router.post(
  "/",
  authenticate,
  authorizeRoles("ADMIN"),
  addRoute
);

router.patch(
  "/:id",
  authenticate,
  authorizeRoles("ADMIN"),
  editRoute
);

export default router;