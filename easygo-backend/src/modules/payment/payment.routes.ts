import {
  Router,
} from "express";

import {
  getPayment,
  initiatePayment,
  listBookingPayments,
  simulatePayment,
} from "./payment.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  authorizeRoles,
} from "../../middleware/role.middleware";

const router =
  Router();

router.post(
  "/",
  authenticate,
  authorizeRoles(
    "CUSTOMER"
  ),
  initiatePayment
);

router.get(
  "/booking/:bookingId",
  authenticate,
  listBookingPayments
);

router.patch(
  "/:id/simulate",
  authenticate,
  authorizeRoles(
    "CUSTOMER"
  ),
  simulatePayment
);

router.get(
  "/:id",
  authenticate,
  getPayment
);

export default router;