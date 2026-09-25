import {
  Request,
  Response,
} from "express";

import {
  createConversation,
  createMessage,
  findThread,
  getConversationById,
  listAgencyStaffUserIds,
  listConversationsForAgency,
  listConversationsForCustomer,
  markConversationRead,
} from "./conversation.service";

import {
  sendMessageSchema,
  startConversationSchema,
} from "./conversation.schema";

import {
  getAgencyById,
} from "../agency/agency.service";

import {
  getStaffMembership,
} from "../staff/staff.service";

import {
  notifySafely,
} from "../notification/notification.service";

const MESSAGING_ROLES = ["CUSTOMER", "AGENCY_STAFF"];

/**
 * Whether the signed-in account is one of the two parties in this thread.
 *
 * The agency side is resolved from the staff membership, so a staff member can
 * only reach their own agency's threads even if they guess another id.
 */
const hasAccess = async (
  userId: string,
  role: string,
  conversation: {
    customerId: string;
    agencyId: string;
  }
) => {
  if (conversation.customerId === userId) {
    return true;
  }

  if (role !== "AGENCY_STAFF") {
    return false;
  }

  const membership = await getStaffMembership(userId);

  return !!membership && membership.agencyId === conversation.agencyId;
};

/** How many of the other party's messages the reader has not seen. */
const countUnread = (
  messages: { senderId: string; readAt: Date | null }[],
  readerId: string
) =>
  messages.filter(
    (message) =>
      message.senderId !== readerId && message.readAt === null
  ).length;

export const startConversation = async (
  req: Request,
  res: Response
) => {
  try {
    if (req.user!.role !== "CUSTOMER") {
      return res.status(403).json({
        success: false,
        message:
          "Only a customer can start a conversation with an agency",
      });
    }

    const validatedData =
      startConversationSchema.parse(req.body);

    const agency = await getAgencyById(
      validatedData.agencyId
    );

    if (!agency) {
      return res.status(404).json({
        success: false,
        message: "Agency not found",
      });
    }

    const customerId = req.user!.userId;

    // Reuse the open thread about the same record rather than opening a
    // duplicate every time the customer writes again.
    const existing = await findThread({
      agencyId: validatedData.agencyId,

      customerId,

      contextReference:
        validatedData.contextReference,
    });

    const conversation =
      existing ??
      (await createConversation({
        agencyId: validatedData.agencyId,

        customerId,

        contextType:
          validatedData.contextType ?? "GENERAL",

        contextReference:
          validatedData.contextReference,
      }));

    await createMessage({
      conversationId: conversation.id,

      senderId: customerId,

      body: validatedData.message,
    });

    const full = await getConversationById(
      conversation.id
    );

    // Let the agency know a customer is waiting, without letting a
    // notification failure lose the message that was already stored.
    const staffIds = await listAgencyStaffUserIds(
      validatedData.agencyId
    );

    for (const staffId of staffIds) {
      await notifySafely({
        userId: staffId,

        title: "New client message",

        message:
          `${agency.name} received a new message from ` +
          `${full?.customer.firstName ?? "a customer"}.`,

        type: "SYSTEM",
      });
    }

    return res.status(201).json({
      success: true,
      message: "Conversation started successfully",
      data: full,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to start the conversation",
    });
  }
};

export const listMyConversations = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = req.user!.userId;
    const role = req.user!.role;

    if (!MESSAGING_ROLES.includes(role)) {
      return res.status(403).json({
        success: false,
        message:
          "Messaging is available to customers and agency staff",
      });
    }

    let conversations;

    if (role === "AGENCY_STAFF") {
      const membership = await getStaffMembership(
        userId
      );

      if (!membership) {
        return res.status(403).json({
          success: false,
          message:
            "Your account is not linked to an agency",
        });
      }

      conversations = await listConversationsForAgency(
        membership.agencyId
      );
    } else {
      conversations = await listConversationsForCustomer(
        userId
      );
    }

    const data = conversations.map(
      (conversation: {
        messages: { senderId: string; readAt: Date | null }[];
      }) => ({
        ...conversation,

        unreadCount: countUnread(
          conversation.messages,
          userId
        ),
      })
    );

    return res.status(200).json({
      success: true,
      count: data.length,
      data,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve conversations",
    });
  }
};

export const getConversation = async (
  req: Request,
  res: Response
) => {
  try {
    const conversationId = String(
      req.params.id
    );

    const conversation = await getConversationById(
      conversationId
    );

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found",
      });
    }

    const allowed = await hasAccess(
      req.user!.userId,
      req.user!.role,
      conversation
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message:
          "You are not a participant in this conversation",
      });
    }

    return res.status(200).json({
      success: true,

      data: {
        ...conversation,

        unreadCount: countUnread(
          conversation.messages,
          req.user!.userId
        ),
      },
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Unable to retrieve the conversation",
    });
  }
};

export const sendMessage = async (
  req: Request,
  res: Response
) => {
  try {
    const conversationId = String(
      req.params.id
    );

    const conversation = await getConversationById(
      conversationId
    );

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found",
      });
    }

    const allowed = await hasAccess(
      req.user!.userId,
      req.user!.role,
      conversation
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message:
          "You are not a participant in this conversation",
      });
    }

    if (conversation.status === "CLOSED") {
      return res.status(400).json({
        success: false,
        message:
          "This conversation has been closed",
      });
    }

    const validatedData =
      sendMessageSchema.parse(req.body);

    await createMessage({
      conversationId,

      senderId: req.user!.userId,

      body: validatedData.body,
    });

    const updated = await getConversationById(
      conversationId
    );

    // Tell the other party there is a reply waiting.
    const isCustomerWriting =
      conversation.customerId === req.user!.userId;

    if (isCustomerWriting) {
      const staffIds = await listAgencyStaffUserIds(
        conversation.agencyId
      );

      for (const staffId of staffIds) {
        await notifySafely({
          userId: staffId,

          title: "New client message",

          message:
            `You have a new message from ` +
            `${conversation.customer.firstName}.`,

          type: "SYSTEM",
        });
      }
    } else {
      await notifySafely({
        userId: conversation.customerId,

        title: "New message from your agency",

        message:
          `${conversation.agency.name} replied to your conversation.`,

        type: "SYSTEM",
      });
    }

    return res.status(201).json({
      success: true,
      message: "Message sent successfully",
      data: updated,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message || "Unable to send the message",
    });
  }
};

export const markRead = async (
  req: Request,
  res: Response
) => {
  try {
    const conversationId = String(
      req.params.id
    );

    const conversation = await getConversationById(
      conversationId
    );

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: "Conversation not found",
      });
    }

    const allowed = await hasAccess(
      req.user!.userId,
      req.user!.role,
      conversation
    );

    if (!allowed) {
      return res.status(403).json({
        success: false,
        message:
          "You are not a participant in this conversation",
      });
    }

    const updatedCount = await markConversationRead({
      conversationId,

      readerId: req.user!.userId,
    });

    return res.status(200).json({
      success: true,
      message: "Conversation marked as read",

      data: {
        updatedCount,
      },
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message:
        error.message ||
        "Unable to mark the conversation as read",
    });
  }
};
