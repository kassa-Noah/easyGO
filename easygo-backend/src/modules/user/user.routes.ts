import { Router } from "express";
import { authenticate } from "../../middleware/auth.middleware";
import { authorizeRoles } from "../../middleware/role.middleware";

import {
  changeUserStatus,
  getMe,
  getUser,
  listUsers,
  updateMe,
} from "./user.controller";

const router = Router();

router.use(authenticate);

router.get("/me", getMe);
router.patch("/me", updateMe);

router.get(
  "/",
  authorizeRoles("ADMIN"),
  listUsers
);

router.get(
  "/:id",
  authorizeRoles("ADMIN"),
  getUser
);

router.patch(
  "/:id/status",
  authorizeRoles("ADMIN"),
  changeUserStatus
);

export default router;