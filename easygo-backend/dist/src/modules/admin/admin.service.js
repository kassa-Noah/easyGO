"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllLuggageForAdmin = exports.getAllParcelsForAdmin = exports.getAllPaymentsForAdmin = exports.getAllBookingsForAdmin = exports.getAdminDashboard = exports.getRecentUsers = exports.getRecentLuggage = exports.getRecentParcels = exports.getRecentPayments = exports.getRecentBookings = exports.getDashboardStatistics = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const getDashboardStatistics = async () => {
    const [totalUsers, activeUsers, totalCustomers, totalAgencyStaff, totalAgencies, activeAgencies, totalTrips, scheduledTrips, completedTrips, totalBookings, pendingBookings, confirmedBookings, completedBookings, cancelledBookings, totalPayments, successfulPayments, pendingPayments, failedPayments, totalTickets, totalLuggage, deliveredLuggage, lostLuggage, totalParcels, deliveredParcels, collectedParcels, lostParcels, totalJourneys, completedJourneys, totalReviews, paymentAggregate,] = await Promise.all([
        prisma_1.default.user.count(),
        prisma_1.default.user.count({
            where: {
                isActive: true,
            },
        }),
        prisma_1.default.user.count({
            where: {
                role: "CUSTOMER",
            },
        }),
        prisma_1.default.user.count({
            where: {
                role: "AGENCY_STAFF",
            },
        }),
        prisma_1.default.agency.count(),
        prisma_1.default.agency.count({
            where: {
                isActive: true,
            },
        }),
        prisma_1.default.trip.count(),
        prisma_1.default.trip.count({
            where: {
                status: "SCHEDULED",
            },
        }),
        prisma_1.default.trip.count({
            where: {
                status: "ARRIVED",
            },
        }),
        prisma_1.default.booking.count(),
        prisma_1.default.booking.count({
            where: {
                status: "PENDING",
            },
        }),
        prisma_1.default.booking.count({
            where: {
                status: "CONFIRMED",
            },
        }),
        prisma_1.default.booking.count({
            where: {
                status: "COMPLETED",
            },
        }),
        prisma_1.default.booking.count({
            where: {
                status: "CANCELLED",
            },
        }),
        prisma_1.default.payment.count(),
        prisma_1.default.payment.count({
            where: {
                status: "SUCCESSFUL",
            },
        }),
        prisma_1.default.payment.count({
            where: {
                status: "PENDING",
            },
        }),
        prisma_1.default.payment.count({
            where: {
                status: "FAILED",
            },
        }),
        prisma_1.default.ticket.count(),
        prisma_1.default.luggage.count(),
        prisma_1.default.luggage.count({
            where: {
                status: "DELIVERED",
            },
        }),
        prisma_1.default.luggage.count({
            where: {
                status: "LOST",
            },
        }),
        prisma_1.default.parcel.count(),
        prisma_1.default.parcel.count({
            where: {
                status: "DELIVERED",
            },
        }),
        prisma_1.default.parcel.count({
            where: {
                status: "COLLECTED",
            },
        }),
        prisma_1.default.parcel.count({
            where: {
                status: "LOST",
            },
        }),
        prisma_1.default.doorToDoorJourney.count(),
        prisma_1.default.doorToDoorJourney.count({
            where: {
                status: "COMPLETED",
            },
        }),
        prisma_1.default.review.count(),
        prisma_1.default.payment.aggregate({
            where: {
                status: "SUCCESSFUL",
            },
            _sum: {
                amount: true,
            },
        }),
    ]);
    return {
        users: {
            total: totalUsers,
            active: activeUsers,
            customers: totalCustomers,
            agencyStaff: totalAgencyStaff,
        },
        agencies: {
            total: totalAgencies,
            active: activeAgencies,
        },
        trips: {
            total: totalTrips,
            scheduled: scheduledTrips,
            arrived: completedTrips,
        },
        bookings: {
            total: totalBookings,
            pending: pendingBookings,
            confirmed: confirmedBookings,
            completed: completedBookings,
            cancelled: cancelledBookings,
        },
        payments: {
            total: totalPayments,
            successful: successfulPayments,
            pending: pendingPayments,
            failed: failedPayments,
            totalSuccessfulAmount: paymentAggregate._sum.amount ??
                0,
        },
        tickets: {
            total: totalTickets,
        },
        luggage: {
            total: totalLuggage,
            delivered: deliveredLuggage,
            lost: lostLuggage,
        },
        parcels: {
            total: totalParcels,
            delivered: deliveredParcels,
            collected: collectedParcels,
            lost: lostParcels,
        },
        journeys: {
            total: totalJourneys,
            completed: completedJourneys,
        },
        reviews: {
            total: totalReviews,
        },
    };
};
exports.getDashboardStatistics = getDashboardStatistics;
const getRecentBookings = async () => {
    return prisma_1.default.booking.findMany({
        take: 10,
        orderBy: {
            createdAt: "desc",
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
                    agency: {
                        select: {
                            id: true,
                            name: true,
                        },
                    },
                    route: {
                        include: {
                            originBranch: {
                                select: {
                                    id: true,
                                    name: true,
                                    city: true,
                                },
                            },
                            destinationBranch: {
                                select: {
                                    id: true,
                                    name: true,
                                    city: true,
                                },
                            },
                        },
                    },
                },
            },
            payments: true,
            ticket: true,
            journey: true,
        },
    });
};
exports.getRecentBookings = getRecentBookings;
const getRecentPayments = async () => {
    return prisma_1.default.payment.findMany({
        take: 10,
        orderBy: {
            createdAt: "desc",
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
                        },
                    },
                    trip: {
                        include: {
                            agency: {
                                select: {
                                    id: true,
                                    name: true,
                                },
                            },
                        },
                    },
                },
            },
        },
    });
};
exports.getRecentPayments = getRecentPayments;
const getRecentParcels = async () => {
    return prisma_1.default.parcel.findMany({
        take: 10,
        orderBy: {
            createdAt: "desc",
        },
        include: {
            sender: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    phone: true,
                },
            },
            recipientUser: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    phone: true,
                },
            },
            originBranch: {
                include: {
                    agency: {
                        select: {
                            id: true,
                            name: true,
                        },
                    },
                },
            },
            destinationBranch: {
                include: {
                    agency: {
                        select: {
                            id: true,
                            name: true,
                        },
                    },
                },
            },
            trip: {
                select: {
                    id: true,
                    departureTime: true,
                    status: true,
                },
            },
        },
    });
};
exports.getRecentParcels = getRecentParcels;
const getRecentLuggage = async () => {
    return prisma_1.default.luggage.findMany({
        take: 10,
        orderBy: {
            createdAt: "desc",
        },
        include: {
            booking: {
                include: {
                    user: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            phone: true,
                        },
                    },
                    trip: {
                        include: {
                            agency: {
                                select: {
                                    id: true,
                                    name: true,
                                },
                            },
                        },
                    },
                },
            },
        },
    });
};
exports.getRecentLuggage = getRecentLuggage;
const getRecentUsers = async () => {
    return prisma_1.default.user.findMany({
        take: 10,
        orderBy: {
            createdAt: "desc",
        },
        select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            role: true,
            isActive: true,
            createdAt: true,
            updatedAt: true,
        },
    });
};
exports.getRecentUsers = getRecentUsers;
const getAdminDashboard = async () => {
    const [statistics, recentBookings, recentPayments, recentParcels, recentLuggage, recentUsers,] = await Promise.all([
        (0, exports.getDashboardStatistics)(),
        (0, exports.getRecentBookings)(),
        (0, exports.getRecentPayments)(),
        (0, exports.getRecentParcels)(),
        (0, exports.getRecentLuggage)(),
        (0, exports.getRecentUsers)(),
    ]);
    return {
        statistics,
        recentActivity: {
            bookings: recentBookings,
            payments: recentPayments,
            parcels: recentParcels,
            luggage: recentLuggage,
            users: recentUsers,
        },
    };
};
exports.getAdminDashboard = getAdminDashboard;
const getAllBookingsForAdmin = async () => {
    return prisma_1.default.booking.findMany({
        orderBy: {
            createdAt: "desc",
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
                },
            },
            payments: true,
            ticket: true,
            journey: true,
            luggage: true,
        },
    });
};
exports.getAllBookingsForAdmin = getAllBookingsForAdmin;
const getAllPaymentsForAdmin = async () => {
    return prisma_1.default.payment.findMany({
        orderBy: {
            createdAt: "desc",
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
                        },
                    },
                },
            },
        },
    });
};
exports.getAllPaymentsForAdmin = getAllPaymentsForAdmin;
const getAllParcelsForAdmin = async () => {
    return prisma_1.default.parcel.findMany({
        orderBy: {
            createdAt: "desc",
        },
        include: {
            sender: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    email: true,
                    phone: true,
                },
            },
            recipientUser: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    email: true,
                    phone: true,
                },
            },
            originBranch: {
                include: {
                    agency: true,
                },
            },
            destinationBranch: {
                include: {
                    agency: true,
                },
            },
            trip: true,
            trackingEvents: {
                orderBy: {
                    createdAt: "asc",
                },
            },
        },
    });
};
exports.getAllParcelsForAdmin = getAllParcelsForAdmin;
const getAllLuggageForAdmin = async () => {
    return prisma_1.default.luggage.findMany({
        orderBy: {
            createdAt: "desc",
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
            trackingEvents: {
                orderBy: {
                    createdAt: "asc",
                },
            },
        },
    });
};
exports.getAllLuggageForAdmin = getAllLuggageForAdmin;
//# sourceMappingURL=admin.service.js.map