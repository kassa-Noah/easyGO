import { Router } from "express";

import {
  getUnreadCount,
  listMyNotifications,
  readAllNotifications,
  readNotification,
} from "./notification.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

const router = Router();

router.get(
  "/me",
  authenticate,
  listMyNotifications
);

router.get(
  "/unread-count",
  authenticate,
  getUnreadCount
);

router.patch(
  "/read-all",
  authenticate,
  readAllNotifications
);

router.patch(
  "/:id/read",
  authenticate,
  readNotification
);

export default router;