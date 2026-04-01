# Task 001 — Environment Setup + First Data Summary

**Portfolio:** Biostatistician Training Program
**Week:** 1 · Day 1
**Language:** R
**Time budget:** 1.5–2 hours
**Commit tag:** `feat: day01 - lung dataset EDA and summary stats`

---

## Overview

You are beginning a 12-week portfolio as a biostatistician-in-training. Every task you complete will be committed to GitHub. By Week 12, this repo will be the primary evidence of your skills when applying for positions or internships.

Treat every file as if a hiring committee will read it — because they will.

---

## Part 1 — Repository Setup

> Estimated time: 30 minutes. Do this before writing any code.

### 1.1 Create your GitHub repository

- Go to [github.com](https://github.com) and create a **new public repository**
- Name it exactly: `biostat-portfolio`
- Initialize it with a `README.md`
- Clone it to your local machine

### 1.2 Create the folder structure

Inside your cloned repo, create the following structure **exactly**:

```
biostat-portfolio/
├── README.md
├── week01/
│   └── day01/
│       ├── analysis.R
│       ├── report.md
│       └── output/
│           └── summary_table.csv
```

You can create empty placeholder files now and fill them in as you work.

### 1.3 Write your root README.md

Your `README.md` (at the root of the repo) must contain:

1. Your name
2. One sentence describing what this repo is
3. A "Table of Contents" section — for now, just list Week 1

**Example:**

```markdown
# Biostatistics Portfolio

**Name:** [Your Name]
**Program:** MSc Biostatistics Training, 2025

This repository documents my 12-week hands-on training in applied biostatistics,
covering descriptive statistics, inference, regression, survival analysis,
epidemiology, and clinical trial methods — using R and Python.

## Table of Contents

- [Week 1 — Foundations: Data Types, EDA, Descriptive Stats](week01/)
```

---

## Part 2 — The Analysis

> Estimated time: 60 minutes.

You will work with the `lung` dataset from R's `survival` package. This is a real clinical dataset of **228 lung cancer patients** from the North Central Cancer Treatment Group. Before writing any code, run `?lung` in your R console and read the documentation.

### 2.1 Load and inspect the data

Create `week01/day01/analysis.R` and write clean, **commented** R code.

```r
# ============================================================
# Task 001 — Lung Cancer Dataset: Initial EDA
# Dataset: lung (survival package)
# Author: [Your Name]
# Date: [Today's date]
# ============================================================

library(survival)
library(dplyr)

# Load the dataset
data(lung)

# Step 1: Inspect structure
# How many rows and columns?
dim(lung)

# What are the variable names and their data types?
str(lung)

# Preview the first 6 rows
head(lung)
```

> **Requirement:** Every logical block of code must have at least one comment explaining what it does and *why*.

### 2.2 Descriptive statistics

Add the following to your `analysis.R`:

Compute and **print** (use `cat()` or `print()`) each of the following:

| What to compute | Variable |
|---|---|
| Mean, median, SD, min, max | `time` (survival time in days) |
| Mean, median, SD, min, max | `age` (patient age in years) |
| Count + percentage by group | `status` (1 = censored, 2 = dead) |
| Count + percentage by group | `sex` (1 = male, 2 = female) |

For the continuous variables (`time`, `age`), your output should look like this when printed:

```
Variable: time
  Mean   : 305.2
  Median : 255.5
  SD     : 210.6
  Min    : 5
  Max    : 1022
```

### 2.3 Missing data audit

Add a section to `analysis.R` that:

1. Counts how many missing values (`NA`) exist in **each column**
2. Calculates what percentage of values are missing per column
3. Prints a warning for any column where **more than 10% of values are missing**

> This is a professional habit. In real clinical data, missing values are never random — they need to be reported and explained.

### 2.4 Export the summary table

Create a clean summary CSV and save it to `output/summary_table.csv`.

The CSV must have these exact columns:

| variable | mean | median | sd | min | max | n_missing |
|---|---|---|---|---|---|---|

- Include **only numeric variables** from the dataset
- Round all values to **2 decimal places**
- One row per variable

**Hint:** You can build this with `dplyr::summarise()` or by constructing a `data.frame()` manually.

---

## Part 3 — The Report

> This is the most important part. Many students write good code but cannot communicate findings. That skill is what separates a biostatistician from a programmer.

Create `week01/day01/report.md` and write a short professional report. Use plain Markdown. **Do not paste your code into this file.**

Your report must contain these four sections:

### Section 1: Dataset description

In 2–3 sentences: What is this dataset? Where does it come from? What does one row represent? Write as if briefing a clinician who will use this data.

### Section 2: Key findings

Write 3–5 bullet points summarizing the most important things you found in your descriptive analysis. Write in plain English — no variable names in backticks, no R output. For example:

> *"The median survival time was 255 days, with substantial variation across patients (SD ≈ 210 days). Approximately 72% of patients had died by the time of data collection..."*

### Section 3: Data quality

Which variables have missing data? What percentage? What might this mean for any analysis that uses those variables? Are there any variables you would be cautious about using?

### Section 4: Next steps

One sentence: what question would you want to investigate next with this data, and why?

---

## Part 4 — Commit Checklist

Before pushing to GitHub, go through this list one item at a time:

- [ ] `analysis.R` runs from **top to bottom without errors** on a fresh R session (test this by restarting R and running the whole file)
- [ ] Every code block has a comment
- [ ] No hardcoded file paths that only work on your machine (use relative paths)
- [ ] `report.md` is written in **complete sentences**, not bullet-point code notes
- [ ] `summary_table.csv` exists, opens correctly, and has the right columns
- [ ] Your repo folder structure matches the spec in Part 1 exactly
- [ ] Your commit message follows this format:

```
feat: day01 - lung dataset EDA and summary stats
```

---

## Grading Criteria

Your mentor will review your commit against these criteria:

| Criteria | What will be checked |
|---|---|
| **Code correctness** | Does the script run clean? Are the numbers right? |
| **Code readability** | Are comments meaningful? Is the code organized? |
| **Statistical accuracy** | Spot-check: mean/SD of `time` and `age`, missing data counts |
| **Report quality** | Is it written for a reader, not a coder? Does it say something real? |
| **Repo structure** | Does it match the spec exactly? |
| **Commit message** | Does it follow the format? |

---

## Bonus (Optional)

If you finish with time to spare:

Produce one plot using `ggplot2` — a histogram of `time`, colored (filled) by `status`. Save it as `output/survival_time_hist.png`.

Add one sentence to your `report.md` under a new heading `### Visualisation` describing what the distribution shows. Does survival time look symmetric? Skewed? What does that tell you clinically?

```r
library(ggplot2)

lung %>%
  mutate(status_label = ifelse(status == 1, "Censored", "Dead")) %>%
  ggplot(aes(x = time, fill = status_label)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  labs(
    title = "Distribution of Survival Time",
    x = "Time (days)",
    y = "Count",
    fill = "Status"
  ) +
  theme_minimal()

ggsave("output/survival_time_hist.png", width = 8, height = 5, dpi = 150)
```

---

## Preview: Day 2

Tomorrow you will work with **probability distributions**. You will simulate data from known distributions (normal, exponential) and compare them visually to the empirical distribution of `time` from today's dataset. The EDA skills from today will be directly reused.

Make sure today's work is pushed and clean before Day 2.

---

*Biostatistics Training Program · Task 001 of 60*
