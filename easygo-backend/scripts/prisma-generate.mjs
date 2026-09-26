// Regenerates the Prisma client after an install.
//
// The generated client is not committed, so a fresh clone is only usable once
// this has run. It is wired to `postinstall` in package.json.
//
// Two things are tolerated deliberately rather than failed:
//
//   * The Prisma CLI lives in devDependencies. An install that omits them
//     (`npm ci --omit=dev`, as a deploy might) has no CLI to run, and that build
//     is expected to have generated the client before shipping. Failing the
//     install there would be worse than saying so.
//   * There is no `.env` yet on a fresh clone. Generation does not need a
//     database, and prisma7.config.ts falls back to a placeholder URL, so this
//     works before anybody has configured anything.
//
// The CLI is run straight from node_modules instead of through `npx`, so a
// machine without it cannot be talked into downloading one, and a generation
// that starts and then fails still exits non-zero rather than being swallowed.

import { existsSync } from "node:fs";
import { spawnSync } from "node:child_process";
import path from "node:path";

const cli = path.join("node_modules", "prisma", "build", "index.js");

if (!existsSync(cli)) {
  console.log(
    "[prisma] The Prisma CLI is not installed, so the client was not " +
      "generated. It ships in devDependencies: run `npm install`, or " +
      "`npx prisma generate`, before building or starting the server.",
  );
  process.exit(0);
}

const result = spawnSync(process.execPath, [cli, "generate"], {
  stdio: "inherit",
});

if (result.status !== 0) {
  console.error(
    "[prisma] Generating the Prisma client failed. The server cannot compile " +
      "without generated/prisma.",
  );
  process.exit(result.status ?? 1);
}
