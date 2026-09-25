import prisma from "../../lib/prisma";

// ======================================================
// MESSAGING
// ======================================================
//
// A conversation belongs to exactly one customer and one agency. Every read and
// write is scoped to a participant: a customer sees only their own threads, and
// agency staff see only their agency's. The agency is resolved from the staff
// membership rather than from anything the client sends.

type ContextType = "BOOKING" | "PARCEL" | "GENERAL";

const conversationInclude = {
  agency: {
    select: {
      id: true,
      name: true,
    },
  },

  customer: {
    select: {
      id: true,
      firstName: true,
      lastName: true,
      email: true,
      phone: true,
    },
  },

  messages: {
    orderBy: {
      createdAt: "asc" as const,
    },

    include: {
      sender: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          role: true,
        },
      },
    },
  },
};

export const listConversationsForCustomer = async (
  customerId: string
) => {
  return prisma.conversation.findMany({
    where: {
      customerId,
    },

    include: conversationInclude,

    orderBy: {
      lastMessageAt: "desc",
    },
  });
};

export const listConversationsForAgency = async (
  agencyId: string
) => {
  return prisma.conversation.findMany({
    where: {
      agencyId,
    },

    include: conversationInclude,

    orderBy: {
      lastMessageAt: "desc",
    },
  });
};

export const getConversationById = async (
  conversationId: string
) => {
  return prisma.conversation.findUnique({
    where: {
      id: conversationId,
    },

    include: conversationInclude,
  });
};

/**
 * The thread this customer already has with this agency about this record, if
 * any. Reusing it stops a second message about the same booking from opening a
 * duplicate thread.
 */
export const findThread = async (data: {
  agencyId: string;
  customerId: string;
  contextReference?: string;
}) => {
  return prisma.conversation.findFirst({
    where: {
      agencyId: data.agencyId,
      customerId: data.customerId,
      status: "OPEN",
      contextReference: data.contextReference ?? null,
    },

    orderBy: {
      createdAt: "desc",
    },
  });
};

export const createConversation = async (data: {
  agencyId: string;
  customerId: string;
  contextType: ContextType;
  contextReference?: string;
}) => {
  return prisma.conversation.create({
    data: {
      agencyId: data.agencyId,
      customerId: data.customerId,
      contextType: data.contextType,
      contextReference: data.contextReference,
    },
  });
};

export const createMessage = async (data: {
  conversationId: string;
  senderId: string;
  body: string;
}) => {
  // The thread's ordering key moves with its newest message, so the write and
  // the bump have to land together.
  return prisma.$transaction(async (tx) => {
    const message = await tx.message.create({
      data: {
        conversationId: data.conversationId,
        senderId: data.senderId,
        body: data.body,
      },
    });

    await tx.conversation.update({
      where: {
        id: data.conversationId,
      },

      data: {
        lastMessageAt: new Date(),
      },
    });

    return message;
  });
};

/**
 * The active staff of an agency, so a new customer message can reach everyone
 * who might answer it.
 */
export const listAgencyStaffUserIds = async (
  agencyId: string
) => {
  const staff = await prisma.agencyStaff.findMany({
    where: {
      agencyId,
      isActive: true,
    },

    select: {
      userId: true,
    },
  });

  return staff.map((member) => member.userId);
};

/**
 * Marks the other side's messages as read. A participant should never be able to
 * mark their own message as read on the other side's behalf.
 */
export const markConversationRead = async (data: {
  conversationId: string;
  readerId: string;
}) => {
  const result = await prisma.message.updateMany({
    where: {
      conversationId: data.conversationId,

      senderId: {
        not: data.readerId,
      },

      readAt: null,
    },

    data: {
      readAt: new Date(),
    },
  });

  return result.count;
};
