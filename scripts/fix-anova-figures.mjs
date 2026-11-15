import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const anovaDeck = resolve(projectRoot, "docs", "anova.html");

if (!existsSync(anovaDeck)) {
  console.log("ANOVA deck is not present; no figure paths to update");
  process.exit(0);
}

const original = readFileSync(anovaDeck, "utf8");
const corrected = original.replace(
  /<img data-src="(anova_files\/figure-revealjs\/[^"]+)"([^>]*)>/g,
  '<img src="$1" loading="eager" decoding="sync"$2>'
);

if (corrected !== original) {
  writeFileSync(anovaDeck, corrected, "utf8");
  console.log("Set ANOVA figures to eager, stable loading");
} else {
  console.log("ANOVA figures already use stable loading");
}
