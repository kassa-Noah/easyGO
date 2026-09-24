import { Router } from "express";

import {
  addBooking,
  cancelMyBooking,
  getBooking,
  listMyBookings,
} from "./booking.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router = Router();

// Customer creates a reservation.
router.post(
  "/",
  authenticate,
  authorizeRoles("CUSTOMER"),
  addBooking
);

// Customer retrieves their bookings.
router.get(
  "/me",
  authenticate,
  authorizeRoles("CUSTOMER"),
  listMyBookings
);

// Authenticated customer, relevant agency
// staff, or administrator retrieves one booking.
router.get(
  "/:id",
  authenticate,
  getBooking
);

// Customer cancels their own booking.
router.patch(
  "/:id/cancel",
  authenticate,
  authorizeRoles("CUSTOMER"),
  cancelMyBooking
);

export default router;