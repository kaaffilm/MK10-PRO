#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const pkgRoot = resolve(here, "..");
const surfaces = JSON.parse(readFileSync(resolve(pkgRoot, "PACKAGE_SURFACES.json"), "utf8"));

const command = process.argv[2] || "surfaces";
const passthrough = process.argv.slice(3);

function print(obj) {
  process.stdout.write(`${JSON.stringify(obj, null, 2)}\n`);
}

function runMk10(args) {
  const result = spawnSync("mk10", args.concat(passthrough), {
    stdio: "inherit",
    env: process.env
  });

  if (result.error && result.error.code === "ENOENT") {
    print({
      package: surfaces.name,
      version: surfaces.version,
      status: "MK10_PRO_PYPI_PACKAGE_NOT_INSTALLED",
      install: "pip install mk10-pro==1.0.3",
      then: `mk10 ${args.join(" ")}`
    });
    process.exit(2);
  }

  process.exit(result.status ?? 1);
}

if (command === "surfaces" || command === "--help" || command === "-h") {
  print({
    package: surfaces.name,
    version: surfaces.version,
    role: surfaces.role,
    source_truth: surfaces.source_truth,
    pypi: surfaces.pypi,
    npm: "npx @kaaffilm/mk10-pro surfaces",
    pkg: "npm install @kaaffilm/mk10-pro --registry=https://npm.pkg.github.com",
    commands: surfaces.commands,
    boundary: surfaces.boundary
  });
  process.exit(0);
}

if (command === "proof") runMk10(["proof"]);
if (command === "boundary") runMk10(["boundary"]);
if (command === "witness") runMk10(["witness"]);

print({
  error: "UNKNOWN_COMMAND",
  command,
  allowed: ["surfaces", "proof", "boundary", "witness"]
});
process.exit(64);
