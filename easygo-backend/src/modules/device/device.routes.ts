import { Router } from "express";

import {
  listMyDevices,
  registerToken,
  releaseToken,
} from "./device.controller";

import {
  authenticate,
} from "../../middleware/auth.middleware";

const router = Router();

router.get(
  "/",
  authenticate,
  listMyDevices
);

router.post(
  "/tokens",
  authenticate,
  registerToken
);

router.delete(
  "/tokens/:token",
  authenticate,
  releaseToken
);

export default router;
