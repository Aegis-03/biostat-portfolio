# Task 006 — Linear Regression: Modelling, Assumptions, Interpretation

**Portfolio:** Biostatistician Training Program
**Week:** 2 · Day 6
**Language:** R
**Time budget:** 1.5–2 hours
**Branch:** `week02/day06-linear-regression`
**Commit tag:** `feat: day06 - linear regression on NHANES blood pressure`

---

## Overview

Every coefficient in a regression model is a hypothesis test. Every p-value you ran yesterday is a special case of regression. Today the pieces connect.

Linear regression is the most widely used statistical method in biomedical research. You will build a model predicting systolic blood pressure from age, BMI, and gender — check whether it meets the four mathematical assumptions that make it valid — and produce a publication-ready regression table that a journal would accept.

By the end of today you will be able to read and critically interpret any linear regression table in a published paper.

---

## Part 1 — Folder Setup

```
biostat-portfolio/
├── week02/
│   ├── day05/
│   └── day06/
│       ├── analysis.R
│       ├── report.Rmd
│       ├── report.html
│       └── output/
│           ├── assumption_plots.png
│           ├── coefficient_plot.png
│           └── partial_effects.png
```

```bash
git checkout main
git pull origin main
git checkout -b week02/day06-linear-regression
```

---

## Part 2 — The Analysis

### 2.1 Load and prepare data

```r
# ============================================================
# Task 006 — Linear Regression
# Outcome: Systolic blood pressure (BPSysAve)
# Predictors: Age, BMI, Gender
# Dataset: NHANES adults (Age >= 18)
# Author: [Your Name]
# Date: [Today's date]
# ============================================================

library(NHANES)
library(dplyr)
library(ggplot2)
library(patchwork)
library(broom)       # tidy() for clean model output
library(gtsummary)   # publication-ready regression tables

data(NHANES)

nhanes <- NHANES %>%
  filter(Age >= 18) %>%
  distinct() %>%
  filter(!is.na(BPSysAve), !is.na(Age), !is.na(BMI), !is.na(Gender)) %>%
  mutate(Gender = factor(Gender, levels = c("female", "male")))  # female = reference
```

Print how many complete cases remain after filtering. Explain why listwise deletion (removing any row with a missing value in any model variable) is the default — and when it can be problematic.

---

### 2.2 Exploratory plots before modelling

Before fitting any model, always visualise the relationships between your outcome and each predictor.

Create a figure with three panels saved as part of your exploratory work (you do not need to save this one — it is for your own understanding):

```r
p_age <- ggplot(nhanes, aes(x = Age, y = BPSysAve)) +
  geom_point(alpha = 0.15, size = 0.6) +
  geom_smooth(method = "lm", color = "steelblue") +
  geom_smooth(method = "loess", color = "firebrick", linetype = "dashed") +
  labs(title = "BP vs Age", x = "Age (years)", y = "Systolic BP (mmHg)") +
  theme_minimal()

p_bmi <- ggplot(nhanes, aes(x = BMI, y = BPSysAve)) +
  geom_point(alpha = 0.15, size = 0.6) +
  geom_smooth(method = "lm", color = "steelblue") +
  geom_smooth(method = "loess", color = "firebrick", linetype = "dashed") +
  labs(title = "BP vs BMI", x = "BMI (kg/m²)", y = "Systolic BP (mmHg)") +
  theme_minimal()

p_gender <- ggplot(nhanes, aes(x = Gender, y = BPSysAve, fill = Gender)) +
  geom_boxplot(alpha = 0.6, outlier.size = 0.5) +
  labs(title = "BP by Gender", x = NULL, y = "Systolic BP (mmHg)") +
  theme_minimal() + theme(legend.position = "none")

print(p_age | p_bmi | p_gender)
```

Look at both the linear fit (blue) and the LOESS curve (red dashed). Are the relationships linear? Does the LOESS diverge from the straight line? These observations will matter when you check assumptions later.

---

### 2.3 Build three models — simple to multiple

Fit models in sequence, always building complexity gradually:

```r
# Model 1: Age only (simple linear regression)
m1 <- lm(BPSysAve ~ Age, data = nhanes)

# Model 2: Age + Gender
m2 <- lm(BPSysAve ~ Age + Gender, data = nhanes)

# Model 3: Age + Gender + BMI (full model)
m3 <- lm(BPSysAve ~ Age + Gender + BMI, data = nhanes)
```

For each model, print the summary and extract these values in a clean format using `broom::tidy()` and `broom::glance()`:

```r
library(broom)

# tidy() gives coefficient estimates, SE, t-stat, p-value
tidy(m1, conf.int = TRUE)
tidy(m2, conf.int = TRUE)
tidy(m3, conf.int = TRUE)

# glance() gives model-level stats: R², adjusted R², AIC, BIC, F-stat
bind_rows(
  glance(m1) %>% mutate(model = "M1: Age"),
  glance(m2) %>% mutate(model = "M2: Age + Gender"),
  glance(m3) %>% mutate(model = "M3: Age + Gender + BMI")
) %>%
  select(model, r.squared, adj.r.squared, AIC, BIC, statistic, p.value) %>%
  print()
```

Print and interpret:
- How much does R² increase from M1 → M2 → M3?
- Does adding each predictor improve the model?
- What is the adjusted R² of the final model, and what does it mean?

---

### 2.4 Interpret the coefficients of Model 3

This is the most important skill in regression. For every coefficient, write what it means in plain English.

```r
m3_tidy <- tidy(m3, conf.int = TRUE) %>%
  mutate(across(where(is.numeric), ~ round(., 3)))

print(m3_tidy)
```

For each row in the output, write an interpretation in this format:

> "Holding all other variables constant, a one-unit increase in [predictor] is associated with a [estimate] mmHg [increase/decrease] in systolic BP (95% CI: [lower, upper], p = [p-value])."

For the gender coefficient specifically:

> "Males have, on average, [estimate] mmHg [higher/lower] systolic BP than females of the same age and BMI (95% CI: ..., p = ...)."

Write these interpretations as comments in your `analysis.R` file, not just in the report.

---

### 2.5 Check the four regression assumptions

A regression model is only valid if four assumptions hold. You must check all four.

```r
# Set up the 4-panel assumption plot
png("output/assumption_plots.png", width = 1400, height = 1200, res = 150)
par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))
plot(m3)
dev.off()
```

The four panels that `plot(lm)` produces, and what to look for in each:

| Panel | What it shows | What "good" looks like |
|---|---|---|
| Residuals vs Fitted | Linearity + homoscedasticity | Points scattered randomly around the horizontal zero line — no funnel shape, no curve |
| Normal Q-Q | Normality of residuals | Points follow the diagonal line closely, especially in the middle |
| Scale-Location | Homoscedasticity | Horizontal red line, points evenly spread — no fan shape |
| Residuals vs Leverage | Influential observations | No points outside Cook's distance lines (dashed) |

After saving the plot, write in `analysis.R` whether each assumption appears satisfied or violated, and why.

---

### 2.6 Coefficient plot

A coefficient plot is a visual regression table — it shows each estimate with its 95% CI as a horizontal bar. This is standard in modern epidemiology papers.

```r
m3_tidy %>%
  filter(term != "(Intercept)") %>%
  mutate(term = recode(term,
    "Age"        = "Age (per year)",
    "Gendermale" = "Gender: Male vs Female",
    "BMI"        = "BMI (per kg/m²)"
  )) %>%
  ggplot(aes(x = estimate, y = term)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),
                 height = 0.2, linewidth = 0.8, color = "steelblue") +
  geom_point(size = 3, color = "steelblue") +
  geom_text(aes(label = paste0("β = ", estimate, "\n95% CI [", conf.low, ", ", conf.high, "]")),
            hjust = -0.1, size = 3, color = "grey30") +
  labs(
    title    = "Regression coefficients — predictors of systolic blood pressure",
    subtitle = "Model 3: BPSysAve ~ Age + Gender + BMI | NHANES adults",
    x        = "Coefficient estimate (mmHg)",
    y        = NULL
  ) +
  theme_minimal() +
  xlim(min(m3_tidy$conf.low[m3_tidy$term != "(Intercept)"], na.rm = TRUE) - 1,
       max(m3_tidy$conf.high[m3_tidy$term != "(Intercept)"], na.rm = TRUE) + 3)

ggsave("output/coefficient_plot.png", width = 9, height = 4, dpi = 150)
```

---

### 2.7 Partial effects plot

A partial effects (marginal effects) plot shows the predicted outcome across the range of one predictor, holding all others at their mean/reference level. This is how you communicate regression results to a clinical audience.

```r
# Create a prediction grid for Age (holding BMI at median, Gender = female)
age_grid <- data.frame(
  Age    = seq(min(nhanes$Age), max(nhanes$Age), length.out = 100),
  BMI    = median(nhanes$BMI),
  Gender = factor("female", levels = c("female", "male"))
)

age_pred <- predict(m3, newdata = age_grid, interval = "confidence") %>%
  as.data.frame() %>%
  bind_cols(age_grid)

p_partial_age <- ggplot(age_pred, aes(x = Age)) +
  geom_ribbon(aes(ymin = lwr, ymax = upr), fill = "steelblue", alpha = 0.2) +
  geom_line(aes(y = fit), color = "steelblue", linewidth = 1) +
  labs(
    title    = "Predicted systolic BP by age",
    subtitle = "BMI held at median; Gender = Female",
    x        = "Age (years)", y = "Predicted systolic BP (mmHg)"
  ) +
  theme_minimal()

# Repeat for BMI (holding Age at mean, Gender = female)
bmi_grid <- data.frame(
  BMI    = seq(min(nhanes$BMI), max(nhanes$BMI), length.out = 100),
  Age    = mean(nhanes$Age),
  Gender = factor("female", levels = c("female", "male"))
)

bmi_pred <- predict(m3, newdata = bmi_grid, interval = "confidence") %>%
  as.data.frame() %>%
  bind_cols(bmi_grid)

p_partial_bmi <- ggplot(bmi_pred, aes(x = BMI)) +
  geom_ribbon(aes(ymin = lwr, ymax = upr), fill = "coral", alpha = 0.2) +
  geom_line(aes(y = fit), color = "coral", linewidth = 1) +
  labs(
    title    = "Predicted systolic BP by BMI",
    subtitle = "Age held at mean; Gender = Female",
    x        = "BMI (kg/m²)", y = "Predicted systolic BP (mmHg)"
  ) +
  theme_minimal()

ggsave("output/partial_effects.png",
       p_partial_age | p_partial_bmi,
       width = 11, height = 4.5, dpi = 150)
```

---

### 2.8 Publication-ready regression table with gtsummary

```r
library(gtsummary)

tbl_regression(m3,
  label = list(
    Age        ~ "Age (years)",
    Gender     ~ "Gender",
    BMI        ~ "BMI (kg/m²)"
  )
) %>%
  add_glance_source_note(
    label = list(r.squared ~ "R²", adj.r.squared ~ "Adjusted R²"),
    include = c(r.squared, adj.r.squared, nobs)
  ) %>%
  bold_p(t = 0.05) %>%
  bold_labels()
```

Export this table to your report. Note: `gtsummary` tables render natively inside R Markdown — no extra steps needed.

---

## Part 3 — The R Markdown Report

Create `week02/day06/report.Rmd`. Required sections:

#### `## Introduction`
2–3 sentences: what question is this regression trying to answer, and why is systolic BP a clinically important outcome?

#### `## Data`
One paragraph: dataset, sample size after filtering, variables used, reference level for gender (female), and why complete-case analysis was used.

#### `## Exploratory Analysis`
Embed the three scatterplots. For each predictor, one sentence: does the relationship with BP appear linear?

#### `## Model Comparison`
Display the R², adjusted R², AIC, and BIC for all three models in a `kable()` table. Write 2–3 sentences: which model fits best and why?

#### `## Coefficient Interpretation`
- Embed the coefficient plot
- Write out the plain-English interpretation of every coefficient in Model 3 (the three sentences in the format shown in Section 2.4)
- State clearly which predictors are statistically significant and which are not

#### `## Assumption Checks`
- Embed `output/assumption_plots.png`
- For each of the four panels, write one sentence: is the assumption satisfied or violated?
- If any assumption is violated, write what you would do next (e.g. add a quadratic term, transform the outcome, use robust SEs)

#### `## Predicted Effects`
- Embed `output/partial_effects.png`
- Write 2–3 sentences interpreting each panel for a clinical reader

#### `## Publication Table`
- Embed the `gtsummary` regression table
- Write one sentence: what does the adjusted R² tell you about how much variance in systolic BP this model explains?

#### `## Limitations`
Write 3 genuine limitations of this analysis. Examples: cross-sectional design, unmeasured confounders, linearity assumption. Write as a numbered list in complete sentences.

#### `## Session Info`

---

## Part 4 — Commit Checklist

- [ ] Branch `week02/day06-linear-regression` used throughout
- [ ] At least 3 meaningful commits
- [ ] All three models fitted and compared
- [ ] All four assumption plots saved and interpreted
- [ ] Coefficient plot and partial effects plots saved correctly
- [ ] `gtsummary` table renders in the knitted HTML
- [ ] Plain-English interpretation written for every coefficient
- [ ] `report.html` knits cleanly with no errors
- [ ] PR opened and merged into `main`
- [ ] Root `README.md` updated

---

## Grading Criteria

| Criteria | What will be checked |
|---|---|
| **Model building** | Three models fitted in sequence; R² comparison correct |
| **Coefficient interpretation** | Every coefficient interpreted in plain English with correct units |
| **Assumption checks** | All four panels addressed individually in the report |
| **Reference level** | Is it clear that female is the reference for gender? |
| **Partial effects** | Prediction grid constructed correctly; confidence band shown |
| **gtsummary table** | Renders cleanly; labels are human-readable |
| **Limitations** | At least 3 genuine, specific limitations — not generic placeholders |

---

## Bonus (Optional)

Test whether the relationship between Age and BP is **non-linear** by adding a quadratic term:

```r
nhanes <- nhanes %>% mutate(Age2 = Age^2)

m4 <- lm(BPSysAve ~ Age + Age2 + Gender + BMI, data = nhanes)

# Compare M3 vs M4 with a likelihood ratio test
anova(m3, m4)
```

If the quadratic term is significant, redo the partial effects plot for Age using M4. Does the predicted curve now match the LOESS curve from your exploratory plot? Add a short paragraph to your report explaining what a non-linear age effect would mean clinically.

---

## Preview: Day 7

Day 7 introduces **logistic regression** — the correct model when your outcome is binary (yes/no, event/no event). You will model the probability of having diabetes using age, BMI, and physical activity. You will learn to interpret odds ratios instead of coefficients, compute predicted probabilities, and draw a ROC curve to evaluate model discrimination. The assumption-checking and model-comparison skills from today transfer directly.

---

*Biostatistics Training Program · Task 006 of 60*
