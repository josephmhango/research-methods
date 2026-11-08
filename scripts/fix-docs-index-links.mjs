import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const docsIndex = resolve(projectRoot, "docs", "index.html");
const original = readFileSync(docsIndex, "utf8");

const corrected = original
  .replace(/("file"\s*:\s*["'])docs\//g, "$1")
  .replace(/(\bfile\s*:\s*["'])docs\//g, "$1");

if (corrected !== original) {
  writeFileSync(docsIndex, corrected, "utf8");
  console.log("Corrected local resource paths in docs/index.html");
} else {
  console.log("Local resource paths in docs/index.html are correct");
}
