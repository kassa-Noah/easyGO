"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAgencyStaffMembership = exports.getUserTickets = exports.getTicketByNumber = exports.getTicketByBookingId = exports.getTicketById = exports.createTicket = exports.getBookingForTicket = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const generateTicketNumber = () => {
    const timestamp = Date.now()
        .toString(36)
        .toUpperCase();
    const randomPart = Math.random()
        .toString(36)
        .substring(2, 8)
        .toUpperCase();
    return `TKT-${timestamp}-${randomPart}`;
};
const generateQrCodeData = (ticketNumber, bookingId) => {
    return JSON.stringify({
        type: "EASYGO_DIGITAL_TICKET",
        ticketNumber,
        bookingId,
    });
};
const getBookingForTicket = async (bookingId) => {
    return prisma_1.default.booking.findUnique({
        where: {
            id: bookingId,
        },
        include: {
            user: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    email: true,
                    phone: true,
                },
            },
            trip: {
                include: {
                    agency: true,
                    route: {
                        include: {
                            originBranch: true,
                            destinationBranch: true,
                        },
                    },
                    vehicle: true,
                },
            },
            payments: true,
            ticket: true,
            journey: true,
        },
    });
};
exports.getBookingForTicket = getBookingForTicket;
const createTicket = async (bookingId) => {
    return prisma_1.default.$transaction(async (tx) => {
        const booking = await tx.booking.findUnique({
            where: {
                id: bookingId,
            },
            include: {
                payments: true,
                ticket: true,
            },
        });
        if (!booking) {
            throw new Error("Booking not found");
        }
        if (booking.status !==
            "CONFIRMED") {
            throw new Error("Only confirmed bookings can receive a ticket");
        }
        const successfulPayment = booking.payments.find((payment) => payment.status ===
            "SUCCESSFUL");
        if (!successfulPayment) {
            throw new Error("A successful payment is required before ticket generation");
        }
        if (booking.ticket) {
            throw new Error("A ticket already exists for this booking");
        }
        const ticketNumber = generateTicketNumber();
        const qrCodeData = generateQrCodeData(ticketNumber, booking.id);
        return tx.ticket.create({
            data: {
                ticketNumber,
                qrCodeData,
                status: "ACTIVE",
                bookingId: booking.id,
            },
            include: {
                booking: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                firstName: true,
                                lastName: true,
                                email: true,
                                phone: true,
                            },
                        },
                        trip: {
                            include: {
                                agency: true,
                                route: {
                                    include: {
                                        originBranch: true,
                                        destinationBranch: true,
                                    },
                                },
                                vehicle: true,
                            },
                        },
                        payments: true,
                        journey: true,
                    },
                },
            },
        });
    });
};
exports.createTicket = createTicket;
const getTicketById = async (ticketId) => {
    return prisma_1.default.ticket.findUnique({
        where: {
            id: ticketId,
        },
        include: {
            booking: {
                include: {
                    user: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                            phone: true,
                        },
                    },
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                            vehicle: true,
                        },
                    },
                    payments: true,
                    journey: true,
                },
            },
        },
    });
};
exports.getTicketById = getTicketById;
const getTicketByBookingId = async (bookingId) => {
    return prisma_1.default.ticket.findUnique({
        where: {
            bookingId,
        },
        include: {
            booking: {
                include: {
                    user: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                            phone: true,
                        },
                    },
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                            vehicle: true,
                        },
                    },
                    payments: true,
                    journey: true,
                },
            },
        },
    });
};
exports.getTicketByBookingId = getTicketByBookingId;
const getTicketByNumber = async (ticketNumber) => {
    return prisma_1.default.ticket.findUnique({
        where: {
            ticketNumber,
        },
        include: {
            booking: {
                include: {
                    user: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                            phone: true,
                        },
                    },
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                            vehicle: true,
                        },
                    },
                },
            },
        },
    });
};
exports.getTicketByNumber = getTicketByNumber;
const getUserTickets = async (userId) => {
    return prisma_1.default.ticket.findMany({
        where: {
            booking: {
                userId,
            },
        },
        include: {
            booking: {
                include: {
                    trip: {
                        include: {
                            agency: true,
                            route: {
                                include: {
                                    originBranch: true,
                                    destinationBranch: true,
                                },
                            },
                            vehicle: true,
                        },
                    },
                },
            },
        },
        orderBy: {
            issuedAt: "desc",
        },
    });
};
exports.getUserTickets = getUserTickets;
const getAgencyStaffMembership = async (userId, agencyId) => {
    return prisma_1.default.agencyStaff.findFirst({
        where: {
            userId,
            agencyId,
            isActive: true,
        },
    });
};
exports.getAgencyStaffMembership = getAgencyStaffMembership;
//# sourceMappingURL=ticket.service.js.map