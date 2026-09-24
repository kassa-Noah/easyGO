"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const review_controller_1 = require("./review.controller");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const role_middleware_1 = require("../../middleware/role.middleware");
const router = (0, express_1.Router)();
router.get("/agency/:agencyId", review_controller_1.listAgencyReviews);
router.post("/", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), review_controller_1.addReview);
router.get("/me", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), review_controller_1.listMyReviews);
router.patch("/:id", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), review_controller_1.editReview);
router.delete("/:id", auth_middleware_1.authenticate, (0, role_middleware_1.authorizeRoles)("CUSTOMER"), review_controller_1.removeReview);
exports.default = router;
//# sourceMappingURL=review.routes.js.map