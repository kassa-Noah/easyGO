import { Router } from "express";

import {
  authenticate,
} from "../../middleware/auth.middleware";

import {
  getConversation,
  listMyConversations,
  markRead,
  sendMessage,
  startConversation,
} from "./conversation.controller";

const router = Router();

// Every route needs a signed-in account. Whether the account is one of the two
// parties in a thread is decided per conversation in the controller, because it
// depends on the thread rather than on the role alone.
router.use(authenticate);

router.post(
  "/",
  startConversation
);

router.get(
  "/",
  listMyConversations
);

router.get(
  "/:id",
  getConversation
);

router.post(
  "/:id/messages",
  sendMessage
);

router.patch(
  "/:id/read",
  markRead
);

export default router;
