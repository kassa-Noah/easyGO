import { Router } from "express";

import {
  generateTicket,
  getBookingTicket,
  getTicket,
  listMyTickets,
  verifyTicket,
} from "./ticket.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router = Router();

// Customer generates a ticket for
// their successfully paid booking.
router.post(
  "/",
  authenticate,
  authorizeRoles("CUSTOMER"),
  generateTicket
);

// Customer retrieves all their tickets.
router.get(
  "/me",
  authenticate,
  authorizeRoles("CUSTOMER"),
  listMyTickets
);

// Retrieve ticket using booking ID.
router.get(
  "/booking/:bookingId",
  authenticate,
  getBookingTicket
);

// Agency staff or administrator
// verifies a ticket number.
router.get(
  "/verify/:ticketNumber",
  authenticate,
  authorizeRoles(
    "AGENCY_STAFF",
    "ADMIN"
  ),
  verifyTicket
);

// Retrieve one ticket by ID.
router.get(
  "/:id",
  authenticate,
  getTicket
);

export default router;