import fs from "node:fs";
import path from "node:path";

const input = process.argv[2];
const output = process.argv[3];

if (!input || !output) {
  throw new Error("Usage: node scripts/build-r-notebook.mjs input.qmd output.ipynb");
}

const sourceText = fs.readFileSync(input, "utf8").replace(/\r\n/g, "\n");
const lines = sourceText.split("\n");

let bodyStart = 0;
let title = path.basename(input, path.extname(input));
let subtitle = "";
let author = "";

if (lines[0]?.trim() === "---") {
  let yamlEnd = 1;
  while (yamlEnd < lines.length && lines[yamlEnd].trim() !== "---") {
    const line = lines[yamlEnd];
    const titleMatch = line.match(/^title:\s*["']?(.*?)["']?\s*$/);
    const subtitleMatch = line.match(/^subtitle:\s*["']?(.*?)["']?\s*$/);
    const authorMatch = line.match(/^author:\s*["']?(.*?)["']?\s*$/);
    if (titleMatch) title = titleMatch[1];
    if (subtitleMatch) subtitle = subtitleMatch[1];
    if (authorMatch) author = authorMatch[1];
    yamlEnd += 1;
  }
  bodyStart = yamlEnd + 1;
}

function sourceLines(text) {
  const cleaned = text.replace(/^\n+|\n+$/g, "");
  if (!cleaned) return [];
  const parts = cleaned.split("\n");
  return parts.map((line, index) => index < parts.length - 1 ? `${line}\n` : line);
}

const cells = [];
let markdownBuffer = [];
let codeBuffer = [];
let inRChunk = false;

function addMarkdown() {
  const text = markdownBuffer.join("\n").trim();
  markdownBuffer = [];
  if (!text) return;
  cells.push({
    cell_type: "markdown",
    id: `cell-${String(cells.length + 1).padStart(3, "0")}`,
    metadata: {},
    source: sourceLines(text)
  });
}

function addCode() {
  const linesWithoutOptions = codeBuffer.filter(line => !line.trim().startsWith("#|"));
  const text = linesWithoutOptions.join("\n").trim();
  codeBuffer = [];
  if (!text) return;
  cells.push({
    cell_type: "code",
    execution_count: null,
    id: `cell-${String(cells.length + 1).padStart(3, "0")}`,
    metadata: {},
    outputs: [],
    source: sourceLines(text)
  });
}

for (const line of lines.slice(bodyStart)) {
  if (!inRChunk && line.trim().startsWith("```{r")) {
    addMarkdown();
    inRChunk = true;
    continue;
  }
  if (inRChunk && line.trim() === "```") {
    addCode();
    inRChunk = false;
    continue;
  }
  if (inRChunk) codeBuffer.push(line);
  else markdownBuffer.push(line);
}

if (inRChunk) throw new Error(`Unclosed R code block in ${input}`);
addMarkdown();

const heading = [
  `# ${title}`,
  subtitle ? `\n*${subtitle}*` : "",
  author ? `\n**${author}**` : ""
].join("").trim();

cells.unshift({
  cell_type: "markdown",
  id: "cell-000",
  metadata: {},
  source: sourceLines(heading)
});

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

fs.writeFileSync(output, `${JSON.stringify(notebook, null, 1)}\n`, "utf8");
