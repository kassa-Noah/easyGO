"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listAllLuggage = exports.listAllParcels = exports.listAllPayments = exports.listAllBookings = exports.dashboardStatistics = exports.dashboard = void 0;
const admin_service_1 = require("./admin.service");
const dashboard = async (_req, res) => {
    try {
        const data = await (0, admin_service_1.getAdminDashboard)();
        return res.status(200).json({
            success: true,
            data,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve admin dashboard",
        });
    }
};
exports.dashboard = dashboard;
const dashboardStatistics = async (_req, res) => {
    try {
        const data = await (0, admin_service_1.getDashboardStatistics)();
        return res.status(200).json({
            success: true,
            data,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve dashboard statistics",
        });
    }
};
exports.dashboardStatistics = dashboardStatistics;
const listAllBookings = async (_req, res) => {
    try {
        const bookings = await (0, admin_service_1.getAllBookingsForAdmin)();
        return res.status(200).json({
            success: true,
            count: bookings.length,
            data: bookings,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve bookings",
        });
    }
};
exports.listAllBookings = listAllBookings;
const listAllPayments = async (_req, res) => {
    try {
        const payments = await (0, admin_service_1.getAllPaymentsForAdmin)();
        return res.status(200).json({
            success: true,
            count: payments.length,
            data: payments,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve payments",
        });
    }
};
exports.listAllPayments = listAllPayments;
const listAllParcels = async (_req, res) => {
    try {
        const parcels = await (0, admin_service_1.getAllParcelsForAdmin)();
        return res.status(200).json({
            success: true,
            count: parcels.length,
            data: parcels,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve parcels",
        });
    }
};
exports.listAllParcels = listAllParcels;
const listAllLuggage = async (_req, res) => {
    try {
        const luggage = await (0, admin_service_1.getAllLuggageForAdmin)();
        return res.status(200).json({
            success: true,
            count: luggage.length,
            data: luggage,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message ||
                "Unable to retrieve luggage",
        });
    }
};
exports.listAllLuggage = listAllLuggage;
//# sourceMappingURL=admin.controller.js.map