import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";

const pkg = JSON.parse(readFileSync(new URL("../package.json", import.meta.url), "utf8"));

if (pkg.name !== "@kaaffilm/mk10-pro") throw new Error("bad package name");
if (pkg.version !== "1.0.3") throw new Error("bad package version");
if (pkg.license !== "Apache-2.0") throw new Error("bad license");

const result = spawnSync("node", ["./bin/mk10-pro.js", "surfaces"], {
  cwd: new URL("..", import.meta.url),
  encoding: "utf8"
});

if (result.status !== 0) throw new Error(result.stderr || "surfaces failed");
if (!result.stdout.includes("source_truth")) throw new Error("missing source_truth");
if (!result.stdout.includes("mk10-pro==1.0.3")) throw new Error("missing PyPI pin");

console.log("MK10-PRO NPM SURFACE: PASS");
