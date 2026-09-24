"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const search_controller_1 = require("./search.controller");
const router = (0, express_1.Router)();
router.get("/trips", search_controller_1.searchAvailableTrips);
exports.default = router;
//# sourceMappingURL=search.routes.js.map