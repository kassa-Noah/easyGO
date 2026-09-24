"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const prisma_1 = __importDefault(require("../lib/prisma"));
async function main() {
    const vehicle = await prisma_1.default.vehicle.findUnique({
        where: {
            registrationNumber: "LT-001-EG",
        },
    });
    if (!vehicle) {
        console.log("Vehicle not found");
        return;
    }
    console.log("VEHICLE ID =", vehicle.id);
    console.log("ID LENGTH =", vehicle.id.length);
    console.log(vehicle);
}
main()
    .catch(console.error)
    .finally(async () => {
    await prisma_1.default.$disconnect();
});
//# sourceMappingURL=check-vehicle.js.map