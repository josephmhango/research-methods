-- Insert reflection breaks at document-specific conceptual boundaries.
-- Each entry identifies the heading that begins the next teaching section;
-- the reflection pause is inserted immediately before that heading.

local break_before = {
  ["week1-literature-review.qmd"] = {
    "section 2: information literacy and discoverability",
    "section 3: scope and research questions",
    "section 4: constructing a search strategy",
    "section 5: from search plan to reproducible protocol",
    "section 6: screening and selecting studies",
    "section 7: reading and critical appraisal",
    "section 8: extraction, synthesis, and writing"
  },
  ["week1-literature-review-guide.qmd"] = {
    "section 2: map information sources and harvest vocabulary",
    "section 3: focus the question and define eligibility",
    "section 4: construct and test the search strategy",
    "section 5: convert the search into a reproducible protocol",
    "section 6: screen records and justify selection",
    "section 7: read purposefully and appraise credibility",
    "section 8: extract, synthesise, and plan the written argument"
  },
  ["week3-scientific-method.qmd"] = {
    "hypothesis (a testable prediction)",
    "analysis and conclusions",
    "principles of scientific reporting"
  },
  ["week3-descriptive-statistics.qmd"] = {
    "different kinds of means exist for a reason",
    "part 2",
    "standard error: a different concept"
  },
  ["week5-data-foundations.qmd"] = {
    "formatting & consistency",
    "section 2: galton",
    "section 3: data types"
  },
  ["week5-data-structures.qmd"] = {
    "part 2 — type conversion",
    "part 3 — core data structures",
    "practice exercises"
  },
  ["week5-data-manipulation.qmd"] = {
    "the central idea",
    "preparing a dataset for analysis",
    "lab"
  },
  ["syntax-basics.qmd"] = {
    "getting help in r",
    "math operators",
    "base r and the tidyverse"
  },
  ["indexing.qmd"] = {
    "indexing with matrices",
    "selection on data.frame objects",
    "practice makes perfect"
  },
  ["tidy-data.qmd"] = {
    "untidy data",
    "getting data into r",
    "practice exercises"
  },
  ["eda.qmd"] = {
    "summarize: weighing the pig",
    "analysis” versus “eda",
    "statistical analysis plan"
  },
  ["t-test.qmd"] = {
    "compare 1 sample to a known mean",
    "3 data and assumptions",
    "typical output of t test function"
  },
  ["chisquare.qmd"] = {
    "a test for discrepancy",
    "demonstrating chi-square in r",
    "some real data"
  },
  ["correlation.qmd"] = {
    "section 2: pearson correlation",
    "section 3: assumptions and diagnostics",
    "section 4: rank correlations and reporting"
  },
  ["fisher.qmd"] = {
    "from means to variance",
    "from f-test to anova",
    "post hoc testing"
  },
  ["anova.qmd"] = {
    "hands‑on: one‑way anova in r",
    "interpreting the q‑q plot",
    "kruskal-wallis: the rank-based counterpart"
  },
  ["1-way-anova.qmd"] = {
    "data and assumptions",
    "anova basic output",
    "anova calculation details"
  },
  ["nonparam.qmd"] = {
    "3: t-test using iris",
    "paired t-test using iris",
    "chi-square test using iris"
  },
  ["week11-sampling-theory.qmd"] = {
    "part 2 – sampling theory",
    "part 3 – spatial sampling in r",
    "judgemental (subjective) approaches"
  },
  ["week11-spatial-sampling.qmd"] = {
    "4. simple random sampling",
    "5. stratified sampling",
    "6. cluster sampling"
  },
  ["week12-regression.qmd"] = {
    "part b — simple linear regression",
    "part c — assumptions and diagnostics",
    "part d — extensions"
  },
  ["regression_tutorial.qmd"] = {
    "part 2: multiple regression",
    "part 3: interactions",
    "part 5: checking your model"
  },
  ["reporting.qmd"] = {
    "methods (the “what did you do?” section)",
    "results (the “what answer did you get?” section)",
    "discussion (the “what does it mean?” section)"
  },
  ["vistut.qmd"] = {
    "2 — grouped line plot",
    "4 — small multiples",
    "mini-section — visualisation principles checklist"
  },
  ["week13-analysis-plan.qmd"] = {
    "step 3 — data preparation",
    "step 5 — assumptions",
    "step 7 — fallback strategies"
  },
  ["week13-effective-graphics.qmd"] = {
    "what is a good graphic?",
    "studio hour",
    "projection + deconstruction loop"
  },
  ["week13-data-visualisation.qmd"] = {
    "gestalt principles",
    "tufte",
    "hans rosling"
  }
}

local function reflection_blocks(number)
  return {
    pandoc.Header(2, "Reflection pause " .. number),
    pandoc.Para({
      pandoc.Strong("Pause for reflection."),
      pandoc.Space(),
      pandoc.Str("Use two minutes to consolidate the concept that has just concluded.")
    }),
    pandoc.BulletList({
      {pandoc.Plain("What is the most important idea from the completed section?")},
      {pandoc.Plain("How would you explain that idea in your own words?")},
      {pandoc.Plain("What question would you like to resolve before continuing?")}
    })
  }
end

local function basename(path)
  local name = path:match("([^/\\]+)$") or path
  name = name:gsub("%.knit%.md$", ".qmd")
  name = name:gsub("%.md$", ".qmd")
  return name
end

function Pandoc(doc)
  local input = PANDOC_STATE.input_files[1]
  local output = PANDOC_STATE.output_file
  local filename = output and basename(output):gsub("%.html$", ".qmd") or
    (input and basename(input) or "")
  local boundaries = break_before[filename]

  -- Files outside the active teaching sequence receive no automatic breaks.
  if boundaries == nil then
    return doc
  end

  local matches = {}
  local next_boundary = 1

  for index, block in ipairs(doc.blocks) do
    if next_boundary <= #boundaries and block.t == "Header" then
      local heading = pandoc.utils.stringify(block.content):lower()
      local pattern = boundaries[next_boundary]:lower()
      if heading:find(pattern, 1, true) then
        table.insert(matches, index)
        next_boundary = next_boundary + 1
      end
    end
  end

  local expected = #boundaries

  if #matches ~= expected then
    io.stderr:write(
      "reflection-pauses.lua: expected " .. expected ..
      " conceptual boundaries for " ..
      filename .. ", found " .. #matches .. "\n"
    )
    return doc
  end

  for number = expected, 1, -1 do
    local blocks = reflection_blocks(number)
    local target = matches[number]
    for offset = #blocks, 1, -1 do
      table.insert(doc.blocks, target, blocks[offset])
    end
  end

  return doc
end
