import {
  Router,
} from "express";

import {
  changeParcelStatus,
  getParcel,
  listMyParcels,
  registerParcel,
  trackParcel,
} from "./parcel.controller";

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
  registerParcel
);

router.get(
  "/me",
  authenticate,
  authorizeRoles(
    "CUSTOMER"
  ),
  listMyParcels
);

router.get(
  "/track/:trackingNumber",
  authenticate,
  trackParcel
);

router.patch(
  "/:id/status",
  authenticate,
  authorizeRoles(
    "AGENCY_STAFF",
    "ADMIN"
  ),
  changeParcelStatus
);

router.get(
  "/:id",
  authenticate,
  getParcel
);

export default router;