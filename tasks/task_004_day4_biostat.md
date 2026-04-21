# Task 004 — Git Workflow + Reproducible Reports with R Markdown

**Portfolio:** Biostatistician Training Program
**Week:** 1 · Day 4
**Language:** R + Git
**Time budget:** 1.5–2 hours
**Commit tag:** `feat: day04 - rmarkdown report and git workflow practice`

---

## Overview

Good analysis that cannot be reproduced is worthless. Today you build the professional habits that turn code into shareable, auditable science.

Two skills today:

1. **Git workflow** — branching, meaningful commits, pull requests. From now on, every task uses this workflow. No more committing directly to `main`.
2. **R Markdown** — converting your Day 3 analysis into a clean, self-contained HTML report that anyone can open and read without touching R.

These are not optional extras. Every serious biostatistician works this way. Hiring managers and collaborators will look at your commit history, not just your code.

---

## Part 1 — Folder Setup

```
biostat-portfolio/
├── week01/
│   ├── day01/
│   ├── day02/
│   ├── day03/
│   └── day04/
│       ├── nhanes_report.Rmd        ← main deliverable
│       ├── nhanes_report.html       ← knitted output (committed)
│       └── .gitignore               ← ignore large data files
```

Update your root `README.md` table of contents.

---

## Part 2 — Git Workflow

From today onwards, **never commit directly to `main`**. Every task follows this pattern:

### 2.1 Create a feature branch

```bash
# Make sure you're on main and up to date
git checkout main
git pull origin main

# Create and switch to a new branch for today's work
git checkout -b week01/day04-rmarkdown
```

Branch names follow the format: `weekXX/dayYY-short-description`

### 2.2 Write meaningful commit messages

Every commit message must follow this structure:

```
<type>: <short description in present tense>

Types:
  feat    — new analysis, new file, new feature
  fix     — correcting an error in existing work
  docs    — README, report text, comments only
  style   — formatting, no logic change
  refactor — reorganising code without changing output
```

**Good:**
```
feat: add nhanes descriptive stats Rmd report
docs: update README with week 1 table of contents
fix: correct missing value handling in describe_numeric
```

**Bad:**
```
update
fixed stuff
day 4 done
wip
```

### 2.3 Commit in logical chunks

Do not commit everything at once at the end. Make at least **3 separate commits** today as you work:

1. After setting up the `.Rmd` file structure and YAML header
2. After completing the analysis sections
3. After finishing the narrative and knitting the final HTML

### 2.4 Push and open a Pull Request

```bash
# Push your branch
git push origin week01/day04-rmarkdown

# Then go to GitHub and open a Pull Request from your branch → main
# Title: "Week 1 Day 4 — NHANES R Markdown Report"
# Description: write 2–3 sentences describing what this PR adds
```

Even though you are working alone, opening a PR is the professional habit. Your mentor can leave comments directly on the PR.

---

## Part 3 — The R Markdown Report

Create `week01/day04/nhanes_report.Rmd`. This document will **re-run your Day 3 analysis** inside a clean, polished report that knits to HTML.

### 3.1 YAML Header

Start your `.Rmd` with this header:

```yaml
---
title: "NHANES Health Indicators — Descriptive Analysis"
author: "[Your Name]"
date: "`r Sys.Date()`"
output:
  html_document:
    theme: flatly
    toc: true
    toc_float: true
    toc_depth: 3
    number_sections: true
    df_print: paged
    code_folding: show
---
```

> `toc_float: true` gives a floating sidebar table of contents. `code_folding: show` lets readers collapse/expand code blocks. These small choices make your reports professional.

### 3.2 Setup chunk

Every R Markdown document starts with a setup chunk. This one must be the first code chunk in your document:

````markdown
```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo    = TRUE,
  warning = FALSE,
  message = FALSE,
  fig.width  = 9,
  fig.height = 5,
  dpi = 150
)
```
````

### 3.3 Report structure

Your `.Rmd` must have these sections (use `##` for level-2 headings):

---

#### `## Introduction`

Write 3–4 sentences:
- What is NHANES?
- What does this report analyse?
- What population is included (adults ≥ 18)?

#### `## Data Preparation`

Code chunk that loads and filters the data. Add a brief sentence after the chunk explaining the number of rows retained and why duplicates were removed.

#### `## Descriptive Statistics`

Paste your `describe_numeric()` function from Day 3 here (in a code chunk). Then call it on the same 5 variables and display the result as a table using `knitr::kable()`:

```r
library(knitr)

summary_table <- bind_rows(
  describe_numeric(nhanes$BMI,      "BMI"),
  describe_numeric(nhanes$Age,      "Age"),
  describe_numeric(nhanes$BPSysAve, "Systolic BP"),
  describe_numeric(nhanes$BPDiaAve, "Diastolic BP"),
  describe_numeric(nhanes$TotChol,  "Total Cholesterol")
)

kable(summary_table,
      digits  = 2,
      caption = "Table 1. Descriptive statistics for key health indicators — NHANES adults (n ≥ 18)",
      col.names = c("Variable", "N", "Missing", "% Missing",
                    "Mean", "Median", "SD", "P25", "P75",
                    "IQR", "Min", "Max", "Skewness", "N Outliers"))
```

After the table, write 2–3 sentences interpreting the most notable findings (in plain text, not a code chunk).

#### `## Distributions by Gender`

Embed your boxplot from Day 3. You can either:
- Re-run the ggplot code inside the `.Rmd` chunk (preferred — keeps report self-contained), or
- Use `knitr::include_graphics("../day03/output/boxplots_by_gender.png")`

Add a figure caption using the chunk option `fig.cap = "Figure 1. ..."`.

Write 2–3 sentences after the figure interpreting the gender differences.

#### `## BMI and Age`

Embed the BMI vs age scatter plot the same way. Write 2–3 sentences interpreting the LOESS trend.

#### `## Missing Data Summary`

Add a dedicated section that displays which variables have missing data. Use `kable()` to show a clean table with just `variable`, `n_missing`, and `pct_missing` — filtered to show only variables with any missing data.

#### `## Key Takeaways`

Write a brief numbered list (in Markdown, not code) of 3–5 conclusions from this analysis. Write as if summarising for a public health colleague who did not read the rest of the report.

#### `## Session Info`

End every report with this chunk — it records the exact R version and package versions used, which is essential for reproducibility:

````markdown
```{r session-info}
sessionInfo()
```
````

### 3.4 Knit the report

When your `.Rmd` is complete:

```r
# In RStudio: click the "Knit" button
# Or from the console:
rmarkdown::render("week01/day04/nhanes_report.Rmd")
```

The output `nhanes_report.html` should open in your browser. Verify:
- The table of contents works and floats correctly
- All figures render
- The `kable()` tables display cleanly
- No error messages appear in the output

**Commit the `.html` file** — this is the deliverable your mentor and future employers will open directly in a browser without needing R installed.

---

## Part 4 — The `.gitignore`

Create `week01/day04/.gitignore` with the following content. This tells Git to ignore files you do not want tracked:

```
# R temporary files
.Rhistory
.RData
.Rproj.user/

# Large data files (load from packages instead)
*.csv
*.rds
*.RData

# OS files
.DS_Store
Thumbs.db
```

> **Why not commit CSVs?** Raw data files belong in data repositories (OSF, Zenodo, figshare) with DOIs, not in code repos. Your code should document how to load the data — not bundle the data itself.

---

## Part 5 — Commit Checklist

Work through this list before merging your PR:

- [ ] You worked on a **feature branch** — not directly on `main`
- [ ] You made **at least 3 commits** with meaningful messages on that branch
- [ ] A Pull Request is open on GitHub with a title and description
- [ ] `nhanes_report.Rmd` exists and knits without errors on a fresh R session
- [ ] `nhanes_report.html` is committed and renders correctly in a browser
- [ ] All 7 required sections are present in the report
- [ ] `kable()` is used for at least 2 tables in the report
- [ ] `.gitignore` is present and correct
- [ ] Root `README.md` updated with Day 4 link
- [ ] After self-review, merge the PR into `main`

---

## Grading Criteria

| Criteria | What will be checked |
|---|---|
| **Git workflow** | Is there a branch? At least 3 commits with meaningful messages? A merged PR? |
| **Rmd knits cleanly** | Zero errors, zero warnings visible in the HTML output |
| **Report structure** | All 7 sections present, headings correctly nested |
| **Table formatting** | `kable()` used with captions and clean column names |
| **Narrative quality** | Prose sections are written for a reader, not a coder |
| **Reproducibility** | Does the `.Rmd` run on a fresh session with no hardcoded paths? |
| **Session info** | Is `sessionInfo()` the last chunk in the document? |

---

## Bonus (Optional)

Add a **themed CSS tweak** to make your report look less like a default template. Inside your YAML header, add:

```yaml
output:
  html_document:
    theme: flatly
    highlight: tango
    css: style.css
```

Create `week01/day04/style.css` with at least:

```css
body {
  font-family: 'Georgia', serif;
  font-size: 15px;
  line-height: 1.8;
}

h1, h2, h3 {
  font-weight: 600;
  color: #2c3e50;
}

.table {
  font-size: 13px;
}

code {
  background-color: #f4f4f4;
  padding: 2px 5px;
  border-radius: 3px;
}
```

Small visual decisions like this signal that you care about your work product, not just the analysis.

---

## Preview: Day 5

Day 5 begins Week 2 — **Hypothesis Testing**. You will run your first formal statistical tests (t-test, Wilcoxon, chi-squared) on the NHANES data, interpret p-values and confidence intervals correctly, and learn the most common misuse of p-values in published research. The R Markdown workflow you set up today will be used for every report from this point forward.

Make sure your PR is merged and `main` is clean before Day 5.

---

*Biostatistics Training Program · Task 004 of 60*
