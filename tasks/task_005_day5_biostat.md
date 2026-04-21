# Task 005 — Hypothesis Testing: t-test, Wilcoxon, Chi-squared

**Portfolio:** Biostatistician Training Program
**Week:** 2 · Day 5
**Language:** R
**Time budget:** 1.5–2 hours
**Branch:** `week02/day05-hypothesis-testing`
**Commit tag:** `feat: day05 - hypothesis testing on NHANES data`

---

## Overview

Week 2 begins. You now know how to describe data — today you learn how to make **claims** about it.

Hypothesis testing is the engine of evidence-based medicine. Every clinical trial result, every published risk factor, every public health policy recommendation is backed by a test like the ones you will run today. But hypothesis testing is also one of the most misused tools in science. By the end of today you will know not just how to run these tests, but what their results actually mean — and what they do not.

Three tests today, applied to real NHANES data:

| Test | Use case |
|---|---|
| Independent samples t-test | Compare means of a continuous variable between 2 groups |
| Wilcoxon rank-sum test | Non-parametric alternative when normality fails |
| Chi-squared test | Compare proportions between categorical groups |

---

## Part 1 — Folder Setup

```
biostat-portfolio/
├── week02/
│   └── day05/
│       ├── analysis.R
│       ├── report.Rmd
│       ├── report.html       ← knitted output, committed
│       └── output/
│           ├── bp_by_gender_test.png
│           ├── bmi_normality_check.png
│           └── diabetes_smoking_table.png
```

Create your branch before writing a single line of code:

```bash
git checkout main
git pull origin main
git checkout -b week02/day05-hypothesis-testing
```

Update your root `README.md` to add a Week 2 section.

---

## Part 2 — The Analysis

### 2.1 Load and prepare data

```r
# ============================================================
# Task 005 — Hypothesis Testing
# Dataset: NHANES
# Author: [Your Name]
# Date: [Today's date]
# ============================================================

library(NHANES)
library(dplyr)
library(ggplot2)
library(moments)
library(patchwork)

set.seed(42)

data(NHANES)
nhanes <- NHANES %>%
  filter(Age >= 18) %>%
  distinct()
```

You will need these variables today. Print their missing-value counts before proceeding:
- `BPSysAve` — average systolic blood pressure
- `BMI` — body mass index
- `Gender` — male / female
- `Diabetes` — Yes / No
- `SmokeNow` — Yes / No

---

### 2.2 Test 1 — Independent samples t-test

**Research question:** Is there a statistically significant difference in mean systolic blood pressure between males and females?

**Step 1 — State the hypotheses formally (as comments in your code):**

```r
# H0: mean systolic BP is equal in males and females (mu_male = mu_female)
# H1: mean systolic BP differs between males and females (mu_male ≠ mu_female)
# Significance level: alpha = 0.05 (two-sided)
```

**Step 2 — Check the normality assumption.** Before running a t-test, verify approximate normality in each group using Shapiro-Wilk (requires n ≤ 5000):

```r
bp_male   <- nhanes %>% filter(Gender == "male",   !is.na(BPSysAve)) %>% pull(BPSysAve)
bp_female <- nhanes %>% filter(Gender == "female",  !is.na(BPSysAve)) %>% pull(BPSysAve)

shapiro.test(sample(bp_male,   min(5000, length(bp_male))))
shapiro.test(sample(bp_female, min(5000, length(bp_female))))
```

**Step 3 — Visualise both groups.** Create and save `output/bp_by_gender_test.png` — two stacked panels:
- Top: overlapping density curves for male vs female systolic BP, with dashed vertical lines at each group mean
- Bottom: Q-Q plots faceted by gender

```r
p1 <- nhanes %>%
  filter(!is.na(BPSysAve), !is.na(Gender)) %>%
  ggplot(aes(x = BPSysAve, fill = Gender, color = Gender)) +
  geom_density(alpha = 0.35, linewidth = 0.8) +
  geom_vline(
    data = nhanes %>%
      filter(!is.na(BPSysAve), !is.na(Gender)) %>%
      group_by(Gender) %>%
      summarise(m = mean(BPSysAve)),
    aes(xintercept = m, color = Gender), linetype = "dashed") +
  labs(title = "Systolic BP distribution by gender",
       x = "Systolic BP (mmHg)", y = "Density") +
  theme_minimal()

p2 <- nhanes %>%
  filter(!is.na(BPSysAve), !is.na(Gender)) %>%
  ggplot(aes(sample = BPSysAve, color = Gender)) +
  stat_qq() + stat_qq_line() +
  facet_wrap(~Gender) +
  labs(title = "Q-Q plots — systolic BP by gender",
       x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_minimal()

ggsave("output/bp_by_gender_test.png", p1 / p2, width = 9, height = 8, dpi = 150)
```

**Step 4 — Run the t-test (Welch's, unequal variances):**

```r
t_result <- t.test(BPSysAve ~ Gender, data = nhanes, var.equal = FALSE)
print(t_result)
```

**Step 5 — Extract and print key values explicitly:**

```r
cat("t-statistic        :", round(t_result$statistic, 3), "\n")
cat("Degrees of freedom :", round(t_result$parameter, 1), "\n")
cat("p-value            :", format.pval(t_result$p.value, digits = 3), "\n")
cat("95% CI for difference in means: [",
    round(t_result$conf.int[1], 2), ",",
    round(t_result$conf.int[2], 2), "]\n")
cat("Mean BP — Male  :", round(t_result$estimate[1], 2), "mmHg\n")
cat("Mean BP — Female:", round(t_result$estimate[2], 2), "mmHg\n")
```

**Step 6 — Compute Cohen's d (effect size):**

```r
bp_data   <- nhanes %>% filter(!is.na(BPSysAve), !is.na(Gender))
n1        <- sum(bp_data$Gender == "male")
n2        <- sum(bp_data$Gender == "female")
sd1       <- sd(bp_data$BPSysAve[bp_data$Gender == "male"])
sd2       <- sd(bp_data$BPSysAve[bp_data$Gender == "female"])
pooled_sd <- sqrt(((n1 - 1)*sd1^2 + (n2 - 1)*sd2^2) / (n1 + n2 - 2))
cohens_d  <- abs(diff(t_result$estimate)) / pooled_sd

cat("Cohen's d:", round(cohens_d, 3),
    "—", ifelse(cohens_d < 0.2, "negligible",
         ifelse(cohens_d < 0.5, "small",
         ifelse(cohens_d < 0.8, "medium", "large"))), "effect\n")
```

> **Key insight:** NHANES has thousands of observations. With this much data, even a 1 mmHg difference will produce p < 0.0001. Always report Cohen's d alongside the p-value. A statistically significant result is not automatically a clinically meaningful one.

---

### 2.3 Test 2 — Wilcoxon rank-sum test

**Research question:** Is BMI distributed differently between males and females?

BMI is typically right-skewed — violating the normality assumption of the t-test. Verify this first:

```r
bmi_data <- nhanes %>% filter(!is.na(BMI), !is.na(Gender))

cat("Skewness — Male BMI:  ", round(skewness(bmi_data$BMI[bmi_data$Gender == "male"]),   3), "\n")
cat("Skewness — Female BMI:", round(skewness(bmi_data$BMI[bmi_data$Gender == "female"]), 3), "\n")
```

Create and save `output/bmi_normality_check.png` — a 2×2 grid:
- Top row: histograms of male and female BMI (with `stat_function()` overlaying a normal curve)
- Bottom row: Q-Q plots for each group

```r
# Build all 4 plots separately then combine with patchwork
# p_hist_m | p_hist_f
# p_qq_m   | p_qq_f
# Use bins = 40 for histograms
```

Run the Wilcoxon rank-sum test:

```r
# H0: BMI distribution is identical in males and females
# H1: BMI distributions differ between males and females

wilcox_result <- wilcox.test(BMI ~ Gender, data = nhanes, conf.int = TRUE)
print(wilcox_result)

cat("W statistic:", wilcox_result$statistic, "\n")
cat("p-value    :", format.pval(wilcox_result$p.value, digits = 3), "\n")
cat("95% CI for location shift: [",
    round(wilcox_result$conf.int[1], 2), ",",
    round(wilcox_result$conf.int[2], 2), "]\n")
```

Also print group medians — the correct summary statistic for a non-parametric test:

```r
bmi_data %>%
  group_by(Gender) %>%
  summarise(
    n      = n(),
    median = median(BMI),
    iqr    = IQR(BMI)
  ) %>%
  print()
```

---

### 2.4 Test 3 — Chi-squared test

**Research question:** Is there an association between diabetes status and current smoking among NHANES adults?

**Step 1 — Build the contingency table:**

```r
# H0: Diabetes status and smoking status are independent
# H1: There is an association between diabetes and smoking

diab_smoke <- nhanes %>%
  filter(!is.na(Diabetes), !is.na(SmokeNow))

cont_table <- table(Diabetes = diab_smoke$Diabetes,
                    SmokeNow = diab_smoke$SmokeNow)
print(cont_table)

# Row proportions — percentage smoking within each diabetes group
print(round(prop.table(cont_table, margin = 1) * 100, 1))
```

**Step 2 — Visualise as a grouped bar chart.** Save as `output/diabetes_smoking_table.png`:

```r
diab_smoke %>%
  count(Diabetes, SmokeNow) %>%
  group_by(Diabetes) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ggplot(aes(x = Diabetes, y = pct, fill = SmokeNow)) +
  geom_col(position = "dodge", width = 0.6) +
  geom_text(aes(label = paste0(round(pct, 1), "%")),
            position = position_dodge(width = 0.6),
            vjust = -0.4, size = 3.5) +
  labs(title = "Smoking prevalence by diabetes status — NHANES adults",
       x = "Diabetes status", y = "Percentage (%)", fill = "Currently smoking") +
  scale_fill_manual(values = c("Yes" = "#e07b5a", "No" = "#5a9ec4")) +
  theme_minimal()

ggsave("output/diabetes_smoking_table.png", width = 7, height = 5, dpi = 150)
```

**Step 3 — Run the chi-squared test:**

```r
chi_result <- chisq.test(cont_table)
print(chi_result)

cat("Chi-squared statistic:", round(chi_result$statistic, 3), "\n")
cat("Degrees of freedom   :", chi_result$parameter, "\n")
cat("p-value              :", format.pval(chi_result$p.value, digits = 3), "\n")

# ALWAYS check expected cell counts — all must be >= 5 for chi-sq to be valid
cat("\nExpected cell counts:\n")
print(round(chi_result$expected, 1))
```

**Step 4 — Compute Cramér's V (effect size):**

```r
n         <- sum(cont_table)
cramers_v <- sqrt(chi_result$statistic /
                  (n * (min(nrow(cont_table), ncol(cont_table)) - 1)))

cat("Cramér's V:", round(cramers_v, 3),
    "—", ifelse(cramers_v < 0.1, "negligible",
         ifelse(cramers_v < 0.3, "small",
         ifelse(cramers_v < 0.5, "medium", "large"))), "association\n")
```

---

## Part 3 — The R Markdown Report

Create `week02/day05/report.Rmd` using the same YAML header and setup chunk as Day 4. Knit to HTML.

### Required sections

#### `## Background`
2–3 sentences: what is hypothesis testing and why is it central to biostatistics?

#### `## The p-value — What it means and what it does not`

This is the most important section of the report. Write it entirely in prose — no code. Answer all three questions:

1. **What does a p-value actually measure?** Be precise. It is the probability of observing a result at least as extreme as yours, *assuming H0 is true*. It is NOT the probability that H0 is true, and it is NOT the probability that your result is due to chance.

2. **Why is p < 0.05 not the same as "important"?** Use your BP result explicitly: state the mean difference in mmHg, the p-value, and Cohen's d. Explain why a result can be highly significant and clinically trivial at the same time.

3. **What must always accompany a p-value?** Effect size, confidence interval, and sample size. Explain briefly why each matters.

#### `## Test 1 — Systolic BP by Gender (t-test)`
- State H0 and H1 in the narrative
- Show the density + Q-Q figure with a proper caption
- Display results in a `kable()` table: Statistic | DF | p-value | 95% CI Lower | 95% CI Upper | Cohen's d | Interpretation
- Interpret in 2–3 sentences: statistically significant? Clinically meaningful?

#### `## Test 2 — BMI by Gender (Wilcoxon)`
- State H0 and H1
- Show the 2×2 normality check figure
- Explain in one sentence why Wilcoxon was chosen
- Display results with medians and IQRs per group in a `kable()` table
- Interpret in 2–3 sentences

#### `## Test 3 — Diabetes and Smoking (Chi-squared)`
- State H0 and H1
- Show the grouped bar chart
- Display the contingency table with row proportions using `kable()`
- Display chi-squared results: Chi-sq | DF | p-value | Cramér's V | Interpretation
- Confirm that all expected cell counts are ≥ 5
- Interpret in 2–3 sentences: is there an association? How strong?

#### `## Reflection — Three things I learned today`
Exactly three numbered sentences. Genuine insights, not summaries of steps.

#### `## Session Info`

---

## Part 4 — Commit Checklist

- [ ] Branch `week02/day05-hypothesis-testing` used — never committed to `main` directly
- [ ] At least 3 meaningful commits on the branch
- [ ] All expected cell counts for chi-squared verified as ≥ 5
- [ ] Cohen's d, location shift CI, and Cramér's V all computed and interpreted
- [ ] Normality checked (Shapiro-Wilk + visual) before choosing t-test vs Wilcoxon
- [ ] `report.html` knits cleanly with no visible errors or warnings
- [ ] Pull Request opened with a title and 2–3 sentence description, then merged
- [ ] Root `README.md` updated with Week 2 + Day 5

---

## Grading Criteria

| Criteria | What will be checked |
|---|---|
| **Test selection** | Right test chosen? Assumptions checked first? |
| **Hypotheses** | H0 and H1 explicitly stated for all three tests |
| **Effect sizes** | All three effect sizes computed, labelled, and interpreted |
| **p-value section** | Correct conceptual understanding demonstrated in prose |
| **Expected counts** | Chi-squared validity explicitly verified in code and report |
| **Git discipline** | Branch, ≥3 commits, PR opened and merged |
| **Report narrative** | Interpretations written for a reader — not pasted R output |

---

## Bonus (Optional)

Run a **one-sample t-test** against the WHO overweight threshold:

```r
# H0: mean BMI in NHANES adults = 25 (WHO overweight threshold)
# H1: mean BMI ≠ 25

bmi_one <- t.test(nhanes$BMI, mu = 25, na.rm = TRUE)
print(bmi_one)
```

Add a short paragraph to your report: is the result statistically significant? What is the effect size (compute Cohen's d against mu = 25)? Does this finding concern you as a public health professional?

---

## Preview: Day 6

Day 6 introduces **linear regression** — the workhorse of biostatistical modelling. You will predict systolic blood pressure from age, BMI, and gender, interpret regression coefficients, check the four core model assumptions, and produce a publication-ready regression table using the `gtsummary` package. The hypothesis testing logic from today is embedded inside every regression coefficient — each one has its own t-test and p-value.

---

*Biostatistics Training Program · Task 005 of 60*
