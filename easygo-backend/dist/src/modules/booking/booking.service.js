"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAgencyStaffMembership = exports.cancelBooking = exports.getBookingById = exports.getUserBookings = exports.createBooking = exports.getTripForBooking = void 0;
const prisma_1 = __importDefault(require("../../lib/prisma"));
const generateBookingReference = () => {
    const timestamp = Date.now()
        .toString(36)
        .toUpperCase();
    const randomPart = Math.random()
        .toString(36)
        .substring(2, 8)
        .toUpperCase();
    return `EG-${timestamp}-${randomPart}`;
};
const getTripForBooking = async (tripId) => {
    return prisma_1.default.trip.findUnique({
        where: {
            id: tripId,
        },
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
    });
};
exports.getTripForBooking = getTripForBooking;
const createBooking = async (data) => {
    return prisma_1.default.$transaction(async (tx) => {
        const trip = await tx.trip.findUnique({
            where: {
                id: data.tripId,
            },
        });
        if (!trip) {
            throw new Error("Trip not found");
        }
        if (trip.status !== "SCHEDULED") {
            throw new Error("Only scheduled trips can be booked");
        }
        if (trip.departureTime <=
            new Date()) {
            throw new Error("Past trips cannot be booked");
        }
        if (trip.availableSeats <
            data.numberOfSeats) {
            throw new Error("Not enough seats are available");
        }
        const tripAmount = Number(trip.price) *
            data.numberOfSeats;
        const bookingReference = generateBookingReference();
        const updatedTrip = await tx.trip.updateMany({
            where: {
                id: data.tripId,
                status: "SCHEDULED",
                availableSeats: {
                    gte: data.numberOfSeats,
                },
            },
            data: {
                availableSeats: {
                    decrement: data.numberOfSeats,
                },
            },
        });
        if (updatedTrip.count !== 1) {
            throw new Error("The requested seats are no longer available");
        }
        const booking = await tx.booking.create({
            data: {
                bookingReference,
                numberOfSeats: data.numberOfSeats,
                tripAmount,
                taxiPickupAmount: 0,
                taxiDropoffAmount: 0,
                totalAmount: tripAmount,
                status: "PENDING",
                userId: data.userId,
                tripId: data.tripId,
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
                        vehicle: true,
                    },
                },
                journey: true,
                payments: true,
                ticket: true,
                luggage: true,
            },
        });
        return booking;
    });
};
exports.createBooking = createBooking;
const getUserBookings = async (userId) => {
    return prisma_1.default.booking.findMany({
        where: {
            userId,
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
                    vehicle: true,
                },
            },
            journey: true,
            payments: true,
            ticket: true,
            luggage: true,
        },
        orderBy: {
            createdAt: "desc",
        },
    });
};
exports.getUserBookings = getUserBookings;
const getBookingById = async (bookingId) => {
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
            journey: {
                include: {
                    taxiAssignments: {
                        include: {
                            provider: true,
                        },
                    },
                },
            },
            payments: true,
            ticket: true,
            luggage: true,
        },
    });
};
exports.getBookingById = getBookingById;
const cancelBooking = async (bookingId) => {
    return prisma_1.default.$transaction(async (tx) => {
        const booking = await tx.booking.findUnique({
            where: {
                id: bookingId,
            },
            include: {
                trip: true,
                journey: true,
            },
        });
        if (!booking) {
            throw new Error("Booking not found");
        }
        if (booking.status ===
            "CANCELLED") {
            throw new Error("Booking is already cancelled");
        }
        if (booking.status ===
            "COMPLETED") {
            throw new Error("A completed booking cannot be cancelled");
        }
        if (booking.trip.departureTime <=
            new Date()) {
            throw new Error("A booking cannot be cancelled after the trip departure time");
        }
        if (booking.journey &&
            booking.journey.status !==
                "PENDING" &&
            booking.journey.status !==
                "CONFIRMED") {
            throw new Error("This booking cannot be cancelled because the door-to-door journey is already in progress");
        }
        const cancelledBooking = await tx.booking.update({
            where: {
                id: bookingId,
            },
            data: {
                status: "CANCELLED",
            },
        });
        await tx.trip.update({
            where: {
                id: booking.tripId,
            },
            data: {
                availableSeats: {
                    increment: booking.numberOfSeats,
                },
            },
        });
        if (booking.journey) {
            await tx.doorToDoorJourney.update({
                where: {
                    id: booking.journey.id,
                },
                data: {
                    status: "CANCELLED",
                },
            });
        }
        return cancelledBooking;
    });
};
exports.cancelBooking = cancelBooking;
const getAgencyStaffMembership = async (userId, agencyId) => {
    return prisma_1.default.agencyStaff.findFirst({
        where: {
            userId,
            agencyId,
        },
    });
};
exports.getAgencyStaffMembership = getAgencyStaffMembership;
//# sourceMappingURL=booking.service.js.map