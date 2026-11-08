import fs from "node:fs";
import path from "node:path";

const projectRoot = path.resolve(import.meta.dirname, "..");
const sourcePath = path.join(projectRoot, "week7-statistical-inference-tutorial.qmd");
const outputPath = path.join(projectRoot, "week7-statistical-inference-tutorial.ipynb");

const raw = fs.readFileSync(sourcePath, "utf8").replace(/\r\n/g, "\n");
const withoutFrontMatter = raw.replace(/^---\n[\s\S]*?\n---\n/, "");
const lines = withoutFrontMatter.split("\n");
const cells = [];
let markdown = [
  "# Week 7 Tutorial: Statistical Inference in R",
  "",
  "**Reusable workflows for t-tests, chi-square tests, correlation and alternative tests**",
  "",
  "K.J. Mhango",
  ""
];

function asSource(textLines) {
  return textLines.map((line, index) =>
    index < textLines.length - 1 ? `${line}\n` : line
  );
}

function flushMarkdown() {
  while (markdown.length && markdown.at(-1) === "") markdown.pop();
  if (!markdown.length) return;
  cells.push({
    cell_type: "markdown",
    metadata: {},
    source: asSource(markdown)
  });
  markdown = [];
}

for (let i = 0; i < lines.length; i += 1) {
  if (lines[i].trim() !== "```{r}") {
    markdown.push(lines[i]);
    continue;
  }

  flushMarkdown();
  const code = [];
  let label = null;
  i += 1;

  while (i < lines.length && lines[i].trim() !== "```") {
    const optionMatch = lines[i].match(/^#\|\s*label:\s*(.+)\s*$/);
    if (optionMatch) label = optionMatch[1].trim();
    if (!lines[i].startsWith("#|")) code.push(lines[i]);
    i += 1;
  }

  while (code.length && code.at(-1) === "") code.pop();
  cells.push({
    cell_type: "code",
    execution_count: null,
    metadata: label ? { tags: [label] } : {},
    outputs: [],
    source: asSource(code)
  });
}

flushMarkdown();

const notebook = {
  cells,
  metadata: {
    kernelspec: {
      display_name: "R",
      language: "R",
      name: "ir"
    },
    language_info: {
      codemirror_mode: "r",
      file_extension: ".r",
      mimetype: "text/x-r-source",
      name: "R",
      pygments_lexer: "r"
    }
  },
  nbformat: 4,
  nbformat_minor: 5
};

fs.writeFileSync(outputPath, `${JSON.stringify(notebook, null, 2)}\n`, "utf8");
console.log(`Created ${path.basename(outputPath)} with ${cells.length} cells.`);
