"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const auth_routes_1 = __importDefault(require("./modules/auth/auth.routes"));
const user_routes_1 = __importDefault(require("./modules/user/user.routes"));
const agency_routes_1 = __importDefault(require("./modules/agency/agency.routes"));
const route_routes_1 = __importDefault(require("./modules/route/route.routes"));
const trip_routes_1 = __importDefault(require("./modules/trip/trip.routes"));
const search_routes_1 = __importDefault(require("./modules/search/search.routes"));
const auth_middleware_1 = require("./middleware/auth.middleware");
const role_middleware_1 = require("./middleware/role.middleware");
const app = (0, express_1.default)();
// Global middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Root endpoint
app.get("/", (_req, res) => {
    res.status(200).json({
        success: true,
        message: "easyGO API is running",
    });
});
// Main API routes
app.use("/api/auth", auth_routes_1.default);
app.use("/api/users", user_routes_1.default);
app.use("/api/agencies", agency_routes_1.default);
app.use("/api/routes", route_routes_1.default);
app.use("/api/trips", trip_routes_1.default);
app.use("/api/search", search_routes_1.default);
// Temporary authorization test routes
app.get("/api/customer-only", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), (req, res) => {
    res.status(200).json({
        success: true,
        message: "Customer route accessed successfully",
        user: req.user,
    });
});
app.get("/api/agency-only", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("AGENCY_STAFF"), (req, res) => {
    res.status(200).json({
        success: true,
        message: "Agency staff route accessed successfully",
        user: req.user,
    });
});
app.get("/api/admin-only", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("ADMIN"), (req, res) => {
    res.status(200).json({
        success: true,
        message: "Admin route accessed successfully",
        user: req.user,
    });
});
app.get("/api/protected", auth_middleware_1.authenticate, (req, res) => {
    res.status(200).json({
        success: true,
        message: "Protected route accessed successfully",
        user: req.user,
    });
});
exports.default = app;
//# sourceMappingURL=app.js.map