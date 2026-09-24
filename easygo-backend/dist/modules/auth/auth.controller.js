"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.login = exports.register = void 0;
const auth_schema_1 = require("./auth.schema");
const auth_service_1 = require("./auth.service");
const register = async (req, res) => {
    try {
        const validatedData = auth_schema_1.registerSchema.parse(req.body);
        const result = await (0, auth_service_1.registerUser)(validatedData);
        res.status(201).json({
            success: true,
            message: "User registered successfully",
            data: result,
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error.message || "Registration failed",
        });
    }
};
exports.register = register;
const login = async (req, res) => {
    try {
        const validatedData = auth_schema_1.loginSchema.parse(req.body);
        const result = await (0, auth_service_1.loginUser)(validatedData);
        res.status(200).json({
            success: true,
            message: "Login successful",
            data: result,
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error.message || "Login failed",
        });
    }
};
exports.login = login;
//# sourceMappingURL=auth.controller.js.map