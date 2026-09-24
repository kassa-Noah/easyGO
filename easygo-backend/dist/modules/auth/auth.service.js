"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.loginUser = exports.registerUser = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const prisma_1 = __importDefault(require("../../lib/prisma"));
const generateToken = (userId, role) => {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new Error("JWT_SECRET is not configured");
    }
    return jsonwebtoken_1.default.sign({
        userId,
        role,
    }, secret, {
        expiresIn: "7d",
    });
};
const registerUser = async (data) => {
    const existingEmail = await prisma_1.default.user.findUnique({
        where: {
            email: data.email,
        },
    });
    if (existingEmail) {
        throw new Error("Email is already registered");
    }
    const existingPhone = await prisma_1.default.user.findUnique({
        where: {
            phone: data.phone,
        },
    });
    if (existingPhone) {
        throw new Error("Phone number is already registered");
    }
    const passwordHash = await bcryptjs_1.default.hash(data.password, 12);
    const user = await prisma_1.default.user.create({
        data: {
            firstName: data.firstName,
            lastName: data.lastName,
            email: data.email.toLowerCase(),
            phone: data.phone,
            passwordHash,
        },
    });
    const token = generateToken(user.id, user.role);
    return {
        user: {
            id: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: user.phone,
            role: user.role,
        },
        token,
    };
};
exports.registerUser = registerUser;
const loginUser = async (data) => {
    const user = await prisma_1.default.user.findUnique({
        where: {
            email: data.email.toLowerCase(),
        },
    });
    if (!user) {
        throw new Error("Invalid email or password");
    }
    if (!user.isActive) {
        throw new Error("This account is disabled");
    }
    const passwordMatches = await bcryptjs_1.default.compare(data.password, user.passwordHash);
    if (!passwordMatches) {
        throw new Error("Invalid email or password");
    }
    const token = generateToken(user.id, user.role);
    return {
        user: {
            id: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: user.phone,
            role: user.role,
        },
        token,
    };
};
exports.loginUser = loginUser;
//# sourceMappingURL=auth.service.js.map