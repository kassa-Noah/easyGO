"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const prisma_1 = __importDefault(require("../lib/prisma"));
async function main() {
    // Remove malformed route
    await prisma_1.default.route.deleteMany({
        where: {
            originBranchId: "b143047d-6d8b-49de-bcf9-7e0b80920bdf",
            destinationBranchId: "f5a7727e-1de0-4dfb-bbfd-531ac3662732",
        },
    });
    console.log("Old malformed route removed.");
    // Create clean route
    const route = await prisma_1.default.route.create({
        data: {
            originBranchId: "b143047d-6d8b-49de-bcf9-7e0b80920bdf",
            destinationBranchId: "f5a7727e-1de0-4dfb-bbfd-531ac3662732",
            distanceKm: 250,
            estimatedDurationMinutes: 240,
            baseFare: 5000,
            isActive: true,
        },
    });
    console.log("NEW ROUTE ID =", route.id);
    console.log("ID LENGTH =", route.id.length);
    console.log(route);
}
main()
    .catch((error) => {
    console.error(error);
    process.exitCode = 1;
})
    .finally(async () => {
    await prisma_1.default.$disconnect();
});
//# sourceMappingURL=create-route.js.map