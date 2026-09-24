"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authorizeRoles = void 0;
const authorizeRoles = (...roles) => (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: "Authentication required",
        });
    }
    if (!roles.includes(req.user.role)) {
        return res.status(403).json({
            success: false,
            message: "Access forbidden",
        });
    }
    next();
};
exports.authorizeRoles = authorizeRoles;
//# sourceMappingURL=role.middleware.js.map