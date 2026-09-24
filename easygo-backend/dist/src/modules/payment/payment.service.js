"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAgencyStaffMembership = exports.completeSimulatedPayment = exports.getPaymentsByBookingId = exports.getPaymentById = exports.createPayment = exports.getPendingPaymentForBooking = exports.getSuccessfulPaymentForBooking = exports.getBookingForPayment = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const generateTransactionReference = () => {
    const timestamp = Date.now()
        .toString(36)
        .toUpperCase();
    const randomPart = Math.random()
        .toString(36)
        .substring(2, 8)
        .toUpperCase();
    return `PAY-${timestamp}-${randomPart}`;
};
const getBookingForPayment = async (bookingId) => {
    return prisma_1.default.booking.findUnique({
        where: {
            id: bookingId,
        },
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
                },
            },
            payments: true,
        },
    });
};
exports.getBookingForPayment = getBookingForPayment;
const getSuccessfulPaymentForBooking = async (bookingId) => {
    return prisma_1.default.payment.findFirst({
        where: {
            bookingId,
            status: "SUCCESSFUL",
        },
    });
};
exports.getSuccessfulPaymentForBooking = getSuccessfulPaymentForBooking;
const getPendingPaymentForBooking = async (bookingId) => {
    return prisma_1.default.payment.findFirst({
        where: {
            bookingId,
            status: "PENDING",
        },
    });
};
exports.getPendingPaymentForBooking = getPendingPaymentForBooking;
const createPayment = async (data) => {
    return prisma_1.default.$transaction(async (tx) => {
        const booking = await tx.booking.findUnique({
            where: {
                id: data.bookingId,
            },
            include: {
                payments: true,
            },
        });
        if (!booking) {
            throw new Error("Booking not found");
        }
        if (booking.status ===
            "CANCELLED") {
            throw new Error("A cancelled booking cannot be paid");
        }
        if (booking.status ===
            "COMPLETED") {
            throw new Error("A completed booking cannot be paid");
        }
        const successfulPayment = booking.payments.find((payment) => payment.status ===
            "SUCCESSFUL");
        if (successfulPayment) {
            throw new Error("This booking has already been paid");
        }
        const pendingPayment = booking.payments.find((payment) => payment.status ===
            "PENDING");
        if (pendingPayment) {
            throw new Error("A payment is already pending for this booking");
        }
        const transactionReference = generateTransactionReference();
        return tx.payment.create({
            data: {
                transactionReference,
                amount: booking.totalAmount,
                method: data.method,
                status: "PENDING",
                bookingId: booking.id,
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
                            },
                        },
                    },
                },
            },
        });
    });
};
exports.createPayment = createPayment;
const getPaymentById = async (paymentId) => {
    return prisma_1.default.payment.findUnique({
        where: {
            id: paymentId,
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
                        },
                    },
                },
            },
        },
    });
};
exports.getPaymentById = getPaymentById;
const getPaymentsByBookingId = async (bookingId) => {
    return prisma_1.default.payment.findMany({
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
                        },
                    },
                },
            },
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getPaymentsByBookingId = getPaymentsByBookingId;
const completeSimulatedPayment = async (paymentId, result) => {
    return prisma_1.default.$transaction(async (tx) => {
        const payment = await tx.payment.findUnique({
            where: {
                id: paymentId,
            },
            include: {
                booking: true,
            },
        });
        if (!payment) {
            throw new Error("Payment not found");
        }
        if (payment.method !==
            "SIMULATED") {
            throw new Error("Only simulated payments can use this operation");
        }
        if (payment.status !==
            "PENDING") {
            throw new Error("Only a pending payment can be processed");
        }
        if (payment.booking.status ===
            "CANCELLED") {
            throw new Error("Payment cannot be completed because the booking is cancelled");
        }
        if (payment.booking.status ===
            "COMPLETED") {
            throw new Error("Payment cannot be completed because the booking is already completed");
        }
        if (result === "FAILED") {
            return tx.payment.update({
                where: {
                    id: payment.id,
                },
                data: {
                    status: "FAILED",
                },
                include: {
                    booking: true,
                },
            });
        }
        const existingSuccessfulPayment = await tx.payment.findFirst({
            where: {
                bookingId: payment.bookingId,
                status: "SUCCESSFUL",
                id: {
                    not: payment.id,
                },
            },
        });
        if (existingSuccessfulPayment) {
            throw new Error("This booking has already been paid");
        }
        const paidAt = new Date();
        await tx.payment.update({
            where: {
                id: payment.id,
            },
            data: {
                status: "SUCCESSFUL",
                paidAt,
            },
        });
        if (payment.booking.status ===
            "PENDING") {
            await tx.booking.update({
                where: {
                    id: payment.bookingId,
                },
                data: {
                    status: "CONFIRMED",
                },
            });
        }
        return tx.payment.findUnique({
            where: {
                id: payment.id,
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
                            },
                        },
                    },
                },
            },
        });
    });
};
exports.completeSimulatedPayment = completeSimulatedPayment;
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
//# sourceMappingURL=payment.service.js.map