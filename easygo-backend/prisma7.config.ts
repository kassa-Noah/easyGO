import "dotenv/config";
import { defineConfig } from "prisma/config";

/// A URL that is never connected to.
///
/// `prisma generate` does not talk to a database, but the CLI still evaluates
/// this config, so a fresh clone with no `.env` would fail to generate the
/// client it needs to compile. Falling back here keeps generation working
/// anywhere. Migrations and the server still need the real DATABASE_URL, and
/// `src/lib/prisma.ts` stops with "DATABASE_URL is not defined" when it is
/// missing, so nothing silently runs against the wrong database.
const generationOnlyUrl = "postgresql://localhost:5432/easygo_db";

export default defineConfig({
  schema: "prisma/schema.prisma",

  migrations: {
    path: "prisma/migrations",
  },

  datasource: {
    url: process.env.DATABASE_URL ?? generationOnlyUrl,
  },
});