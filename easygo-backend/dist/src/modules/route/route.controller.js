"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.editRoute = exports.addRoute = exports.getRoute = exports.listRoutes = void 0;
const route_service_1 = require("./route.service");
const route_schema_1 = require("./route.schema");
const listRoutes = async (_req, res) => {
    try {
        const routes = await (0, route_service_1.getAllRoutes)();
        return res.status(200).json({
            success: true,
            data: routes,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve routes",
        });
    }
};
exports.listRoutes = listRoutes;
const getRoute = async (req, res) => {
    try {
        const routeId = String(req.params.id);
        const route = await (0, route_service_1.getRouteById)(routeId);
        if (!route) {
            return res.status(404).json({
                success: false,
                message: "Route not found",
            });
        }
        return res.status(200).json({
            success: true,
            data: route,
        });
    }
    catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message || "Unable to retrieve route",
        });
    }
};
exports.getRoute = getRoute;
const addRoute = async (req, res) => {
    try {
        const validatedData = route_schema_1.createRouteSchema.parse(req.body);
        if (validatedData.originBranchId ===
            validatedData.destinationBranchId) {
            return res.status(400).json({
                success: false,
                message: "Origin and destination branches cannot be the same",
            });
        }
        const originBranch = await (0, route_service_1.getBranchById)(validatedData.originBranchId);
        if (!originBranch) {
            return res.status(404).json({
                success: false,
                message: "Origin branch not found",
            });
        }
        const destinationBranch = await (0, route_service_1.getBranchById)(validatedData.destinationBranchId);
        if (!destinationBranch) {
            return res.status(404).json({
                success: false,
                message: "Destination branch not found",
            });
        }
        const existingRoute = await (0, route_service_1.findExistingRoute)(validatedData.originBranchId, validatedData.destinationBranchId);
        if (existingRoute) {
            return res.status(409).json({
                success: false,
                message: "This route already exists",
            });
        }
        const route = await (0, route_service_1.createRoute)(validatedData);
        return res.status(201).json({
            success: true,
            message: "Route created successfully",
            data: route,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to create route",
        });
    }
};
exports.addRoute = addRoute;
const editRoute = async (req, res) => {
    try {
        const routeId = String(req.params.id);
        const existingRoute = await (0, route_service_1.getRouteById)(routeId);
        if (!existingRoute) {
            return res.status(404).json({
                success: false,
                message: "Route not found",
            });
        }
        const validatedData = route_schema_1.updateRouteSchema.parse(req.body);
        const originBranchId = validatedData.originBranchId ??
            existingRoute.originBranchId;
        const destinationBranchId = validatedData.destinationBranchId ??
            existingRoute.destinationBranchId;
        if (originBranchId === destinationBranchId) {
            return res.status(400).json({
                success: false,
                message: "Origin and destination branches cannot be the same",
            });
        }
        if (validatedData.originBranchId) {
            const origin = await (0, route_service_1.getBranchById)(validatedData.originBranchId);
            if (!origin) {
                return res.status(404).json({
                    success: false,
                    message: "Origin branch not found",
                });
            }
        }
        if (validatedData.destinationBranchId) {
            const destination = await (0, route_service_1.getBranchById)(validatedData.destinationBranchId);
            if (!destination) {
                return res.status(404).json({
                    success: false,
                    message: "Destination branch not found",
                });
            }
        }
        const route = await (0, route_service_1.updateRoute)(routeId, validatedData);
        return res.status(200).json({
            success: true,
            message: "Route updated successfully",
            data: route,
        });
    }
    catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message || "Unable to update route",
        });
    }
};
exports.editRoute = editRoute;
//# sourceMappingURL=route.controller.js.map