# Task 003 — Descriptive Statistics in Depth + First Reusable Function

**Portfolio:** Biostatistician Training Program
**Week:** 1 · Day 3
**Language:** R
**Time budget:** 1.5–2 hours
**Commit tag:** `feat: day03 - descriptive stats, NHANES EDA, reusable function`

---

## Overview

The first two days used the `lung` dataset. Today you work with **NHANES** — the National Health and Nutrition Examination Survey, a large ongoing US public health study that combines interviews, physical examinations, and lab tests from thousands of adults. This is the kind of messy, real-world dataset you will encounter constantly in epidemiology and clinical research.

Two new skills today:

1. **Deeper descriptive statistics** — beyond mean and SD, you will compute percentiles, interquartile range, and detect outliers systematically
2. **Your first reusable R function** — instead of copy-pasting the same summary code for each variable, you will write one function and call it cleanly

---

## Part 1 — Folder Setup

```
biostat-portfolio/
├── week01/
│   ├── day01/
│   ├── day02/
│   └── day03/
│       ├── analysis.R
│       ├── report.md
│       └── output/
│           ├── nhanes_summary.csv
│           ├── boxplots_by_gender.png
│           └── bmi_age_scatter.png
```

Update your root `README.md` table of contents.

---

## Part 2 — The Analysis

### 2.1 Load the NHANES dataset

The `NHANES` dataset is available in the R package of the same name.

```r
install.packages("NHANES")   # run once, then comment out
library(NHANES)
library(dplyr)
library(ggplot2)

data(NHANES)
```

Run `?NHANES` and `str(NHANES)` to understand what variables are available. You are working with **adult participants only** (age ≥ 18). Filter the dataset immediately:

```r
nhanes <- NHANES %>%
  filter(Age >= 18) %>%
  distinct()          # remove duplicate survey IDs
```

Print: how many rows remain after filtering?

### 2.2 Write a reusable summary function

Instead of writing the same `mean()`, `median()`, `sd()` block for every variable, write one function called `describe_numeric()` that takes a numeric vector and returns a named list (or single-row data frame) with:

| Output field | What it computes |
|---|---|
| `n` | Number of non-missing values |
| `n_missing` | Number of NAs |
| `pct_missing` | Percentage missing, rounded to 1 decimal |
| `mean` | Mean, rounded to 2 decimal places |
| `median` | Median |
| `sd` | Standard deviation |
| `p25` | 25th percentile |
| `p75` | 75th percentile |
| `iqr` | Interquartile range (p75 − p25) |
| `min` | Minimum |
| `max` | Maximum |
| `skewness` | Skewness (use `moments::skewness()`) |
| `n_outliers` | Number of values beyond 1.5 × IQR from Q1/Q3 |

```r
library(moments)

describe_numeric <- function(x, varname = "variable") {
  x_clean <- x[!is.na(x)]
  q1  <- quantile(x_clean, 0.25)
  q3  <- quantile(x_clean, 0.75)
  iqr <- q3 - q1

  data.frame(
    variable   = varname,
    n          = length(x_clean),
    n_missing  = sum(is.na(x)),
    pct_missing = round(mean(is.na(x)) * 100, 1),
    mean       = round(mean(x_clean), 2),
    median     = round(median(x_clean), 2),
    sd         = round(sd(x_clean), 2),
    p25        = round(q1, 2),
    p75        = round(q3, 2),
    iqr        = round(iqr, 2),
    min        = round(min(x_clean), 2),
    max        = round(max(x_clean), 2),
    skewness   = round(skewness(x_clean), 3),
    n_outliers = sum(x_clean < (q1 - 1.5 * iqr) | x_clean > (q3 + 1.5 * iqr))
  )
}
```

> Once this function works, you will be able to summarize any numeric variable in one line. This is what it means to write reusable code.

### 2.3 Apply the function to key variables

Apply `describe_numeric()` to these five variables from `nhanes`:

- `BMI`
- `Age`
- `BPSysAve` (average systolic blood pressure)
- `BPDiaAve` (average diastolic blood pressure)
- `TotChol` (total cholesterol)

Combine all results into a single data frame using `bind_rows()` and save it to `output/nhanes_summary.csv`.

```r
summary_table <- bind_rows(
  describe_numeric(nhanes$BMI,      "BMI"),
  describe_numeric(nhanes$Age,      "Age"),
  describe_numeric(nhanes$BPSysAve, "BPSysAve"),
  describe_numeric(nhanes$BPDiaAve, "BPDiaAve"),
  describe_numeric(nhanes$TotChol,  "TotChol")
)

write.csv(summary_table, "output/nhanes_summary.csv", row.names = FALSE)
print(summary_table)
```

### 2.4 Boxplots by gender

Create a figure with **5 side-by-side boxplots** — one for each variable above — split by `Gender`. Save as `output/boxplots_by_gender.png`.

Requirements:
- Use `facet_wrap()` with `scales = "free_y"` so each variable uses its own y-axis
- Color the boxes by `Gender`
- Add a horizontal dashed line at each variable's **median** (compute per group)
- Label outlier points (hint: use `geom_boxplot(outlier.size = 0.8, outlier.alpha = 0.4)` to show them without clutter)
- Use `theme_minimal()` and a clean legend

```r
# Reshape to long format first — ggplot works best this way
library(tidyr)

nhanes_long <- nhanes %>%
  select(Gender, BMI, Age, BPSysAve, BPDiaAve, TotChol) %>%
  pivot_longer(cols = -Gender, names_to = "variable", values_to = "value") %>%
  filter(!is.na(value), !is.na(Gender))

ggplot(nhanes_long, aes(x = Gender, y = value, fill = Gender)) +
  geom_boxplot(outlier.size = 0.8, outlier.alpha = 0.4) +
  facet_wrap(~variable, scales = "free_y") +
  labs(title = "Distribution of key health indicators by gender — NHANES",
       x = NULL, y = "Value") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("output/boxplots_by_gender.png", width = 10, height = 6, dpi = 150)
```

### 2.5 BMI vs age scatter plot

Create a scatter plot of `BMI` (y-axis) against `Age` (x-axis), saved as `output/bmi_age_scatter.png`.

Requirements:
- Color points by `Gender`
- Add a **LOESS smoothing line** per gender group using `geom_smooth(method = "loess")`
- Use `alpha = 0.3` on points to reduce overplotting
- Add proper axis labels and a title

```r
nhanes %>%
  filter(!is.na(BMI), !is.na(Age), !is.na(Gender)) %>%
  ggplot(aes(x = Age, y = BMI, color = Gender)) +
  geom_point(alpha = 0.3, size = 0.8) +
  geom_smooth(method = "loess", se = TRUE, linewidth = 1.2) +
  labs(title = "BMI vs age by gender — NHANES adults",
       x = "Age (years)", y = "BMI (kg/m²)") +
  theme_minimal()

ggsave("output/bmi_age_scatter.png", width = 8, height = 5, dpi = 150)
```

---

## Part 3 — The Report

Write `week01/day03/report.md`. No code, plain English.

### Section 1: About NHANES

In 2–3 sentences: what is NHANES, who collects it, and why is it useful for public health research? (Use `?NHANES` and any public source.)

### Section 2: Key findings from the summary table

Look at your `nhanes_summary.csv`. Answer these questions in paragraph form:

- Which variable has the most missing data, and what percentage is missing?
- Which variable is most skewed? What does that skewness tell you about the underlying phenomenon?
- Which variable has the most outliers by the 1.5 × IQR rule? Does that seem clinically plausible?

### Section 3: Gender differences

Look at your `boxplots_by_gender.png`. In 3–5 sentences:
- Are there meaningful differences between males and females in BMI, blood pressure, or cholesterol?
- Are the medians noticeably different, or do the distributions mostly overlap?
- Name one finding that you would flag if presenting this data to a public health audience.

### Section 4: BMI and age

Look at your `bmi_age_scatter.png`. Describe what the LOESS curve shows:
- Does BMI increase, plateau, or decline with age?
- Is the trend the same for both genders?
- What does the width of the confidence band tell you about certainty across the age range?

### Section 5: The value of a reusable function

In 2–3 sentences: what was the advantage of writing `describe_numeric()` instead of repeating the same code five times? What would you add to this function if you needed to use it in a professional report?

---

## Part 4 — Commit Checklist

- [ ] `describe_numeric()` is defined **once** and called five times — no copy-pasted blocks
- [ ] Script runs top to bottom without errors on a fresh R session
- [ ] `nhanes_summary.csv` exists with 5 rows and 14 columns
- [ ] Both PNG files are saved and clearly readable
- [ ] `report.md` answers all five sections in complete sentences
- [ ] Root `README.md` updated with Day 3 link
- [ ] Commit message: `feat: day03 - descriptive stats, NHANES EDA, reusable function`

---

## Grading Criteria

| Criteria | What will be checked |
|---|---|
| **Function correctness** | Does `describe_numeric()` return the right values for all 14 fields? |
| **Code structure** | Is the function defined once and reused cleanly? |
| **Plot quality** | All required elements present, faceting correct, LOESS visible |
| **Missing data awareness** | Does the function handle NAs correctly without crashing? |
| **Report depth** | Does the student interpret findings, not just describe them? |
| **CSV format** | Correct column names, 5 rows, all values rounded properly |

---

## Bonus (Optional)

Extend `describe_numeric()` to also return a **normality test result**: run `shapiro.test()` on the first 5000 values (Shapiro-Wilk requires n ≤ 5000) and add two fields to the output:

- `shapiro_W` — the W statistic
- `shapiro_p` — the p-value

Add one sentence per variable in your report: does the test suggest the variable is normally distributed? Does this match what you saw in the QQ plots from Day 2?

---

## Preview: Day 4

Day 4 covers **Git workflow and R Markdown** — the professional habits that turn good analysis into shareable, reproducible work. You will convert your Day 3 analysis into a clean `.Rmd` document that knits to an HTML report, and practice branching, pull requests, and commit conventions. Every future task in this portfolio will use these habits.

---

*Biostatistics Training Program · Task 003 of 60*
