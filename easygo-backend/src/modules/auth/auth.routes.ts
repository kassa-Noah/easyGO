import { Router } from "express";
import { changePassword, login, register } from "./auth.controller";
import { authenticate } from "../../middleware/auth.middleware";

const router = Router();

router.post("/register", register);
router.post("/login", login);

// Changing a password needs the account it belongs to, so this route is
// authenticated rather than taking an email from the body.
router.post(
  "/change-password",
  authenticate,
  changePassword
);

export default router;