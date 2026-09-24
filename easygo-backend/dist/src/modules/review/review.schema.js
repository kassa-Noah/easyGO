"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateReviewSchema = exports.createReviewSchema = void 0;
const zod_1 = require("zod");
exports.createReviewSchema = zod_1.z.object({
    agencyId: zod_1.z
        .string()
        .uuid("Invalid agency ID"),
    tripId: zod_1.z
        .string()
        .uuid("Invalid trip ID"),
    rating: zod_1.z
        .number()
        .int("Rating must be an integer")
        .min(1, "Rating must be at least 1")
        .max(5, "Rating cannot exceed 5"),
    comment: zod_1.z
        .string()
        .trim()
        .max(1000, "Comment cannot exceed 1000 characters")
        .optional(),
});
exports.updateReviewSchema = zod_1.z
    .object({
    rating: zod_1.z
        .number()
        .int("Rating must be an integer")
        .min(1, "Rating must be at least 1")
        .max(5, "Rating cannot exceed 5")
        .optional(),
    comment: zod_1.z
        .string()
        .trim()
        .max(1000, "Comment cannot exceed 1000 characters")
        .optional(),
})
    .refine((data) => data.rating !== undefined ||
    data.comment !== undefined, {
    message: "At least one field must be provided",
});
//# sourceMappingURL=review.schema.js.map