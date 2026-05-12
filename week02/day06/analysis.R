#============================================================
# Task 005 — Linear Regression
# Outcome: Systolic blood pressure (BPSysAve)
# Predictors: Age, BMI, Gender
# Dataset: NHANES adults (Age >= 18)
# Author: [T.V.Q]
# Date: [11 May 2026]
# ============================================================


# Load the library
library(NHANES)     # For NHANES dataset
library(dplyr)      # For data manipulation
library(ggplot2)    # For graphs
library(patchwork)  # To combine multiple plots into a single layout
library(broom)      # For tidy() function
library(gtsummary)  # For publication-ready regression tables


#==================================================
# 1. Prepare data
#==================================================

# Filter adult population (Age >= 18)
# Remove duplicated rows
# Listwise deletion: remove entire row is excluded if
#   any single value of target variables is missing
# Modify "Gender" column by factoring the categorical variable into levels
#   "female" is the reference level
nhanes <- NHANES |>
  filter(Age >= 18) |>
  distinct() |>
  filter(!is.na(BPSysAve), !is.na(Age), !is.na(BMI), !is.na(Gender)) |>
  mutate(Gender = factor(Gender, levels = c("female", "male")))


# Print number of complete cases remain after filtering
cat("There are:", nrow(nhanes), "complete cases remain after filtering", "\n")

# Interpretation:
# Listwise deletion is a defalt method for handling missing data because
#   it is simple and efficient. The processed dataset is complete
# Listwise deletion produces unbiased estimates only if data is Missing
#   Completely at Random (MCAR), meaning the missingness is not related
#   to any observed or unobserved data.
# If data is not MCAR, listwise deletion often results in biased parameters
#   and estimates

#==================================================
# 2. Visualize data
#==================================================

# Scatter plot with linear fit and the LOESS curve
#   Variables: BPSysAve vs Age
p_age <- ggplot(nhanes, aes(x = Age, y = BPSysAve)) +
  geom_point(alpha = 0.15, size = 0.6) +
  geom_smooth(method = "lm", color = "steelblue") +
  geom_smooth(method = "loess", color = "firebrick", linetype = "dashed") +
  labs(title = "BP vs Age", x = "Age (years)", y = "Systolic BP (mmHg)") +
  theme_minimal()

#   Variables: BPSysAve vs BMI
p_bmi <- ggplot(nhanes, aes(x = BMI, y = BPSysAve)) +
  geom_point(alpha = 0.15, size = 0.6) +
  geom_smooth(method = "lm", color = "steelblue") +
  geom_smooth(method = "loess", color = "firebrick", linetype = "dashed") +
  labs(title = "BP vs BMI", x = "BMI (kg/m²)", y = "Systolic BP (mmHg)") +
  theme_minimal()

# Box plot
#   Variables: BPSysAve vs Gender
p_gender <- ggplot(nhanes, aes(x = Gender, y = BPSysAve, fill = Gender)) +
  geom_boxplot(alpha = 0.6, outlier.size = 0.5) +
  labs(title = "BP by Gender", x = NULL, y = "Systolic BP (mmHg)") +
  theme_minimal() + theme(legend.position = "none")

# Print the combined plot
print(p_age / p_bmi / p_gender)

# Interpretation:
# BPSysAve vs Age:
#   The relationship seems to be linear, the LOESS does not diverge
#   from the straight line
# BPSysAve vs BMI
#   The relationship does not seem to be linear, the LOESS diverges
#   from the straight line


#==================================================
# 3. Build regression models
#==================================================

# Model 1: Age only (simple linear regression)
m1 <- lm(BPSysAve ~ Age, data = nhanes)

# Summary table of model 1 with coefficient estimates, SE, t-stat, p-value
print(tidy(m1, conf.int = TRUE))

# Summary table of model 1 with R², adjusted R², AIC, BIC, F-stat
glance(m1) |>
  mutate(model = "M1: Age") |>
  select(model, r.squared, adj.r.squared, AIC, BIC, statistic, p.value) |>
  print()

# Model 2: Age + Gender
m2 <- lm(BPSysAve ~ Age + Gender, data = nhanes)

# Summary table of model 2 with coefficient estimates, SE, t-stat, p-value
print(tidy(m2, conf.int = TRUE))

# Summary table of model 2 with R², adjusted R², AIC, BIC, F-stat
glance(m2) |>
  mutate(model = "M2: Age + Gender") |>
  select(model, r.squared, adj.r.squared, AIC, BIC, statistic, p.value) |>
  print()

# Model 3: Age + Gender + BMI (full model)
m3 <- lm(BPSysAve ~ Age + Gender + BMI, data = nhanes)

# Summary table of model 3 with coefficient estimates, SE, t-stat, p-value
print(tidy(m3, conf.int = TRUE))

# Summary table of model 3 with R², adjusted R², AIC, BIC, F-stat
glance(m3) |>
  mutate(model = "M3: Age + Gender + BMI") |>
  select(model, r.squared, adj.r.squared, AIC, BIC, statistic, p.value) |>
  print()

# Interpretation:
# R² increases from 0.187 to 0.206 to 0.215 from M1 to M2 to M3
# Adding each predictor does not improve the model
# Adjusted R² in the final model is 0.215
# Adjusted R² is a modified version of R² that adjusts for the number of
#   predictors Unlike R², which always increases when new variables are added,
#   adjusted R² only increases if a new predictor improves the model's accuracy
#   more than expected by chance

#==================================================
# 4. Interpret model coefficients
#==================================================

# Round all numeric columns in smmary table of model 3 to 3 decimal places
m3_tidy <- tidy(m3, conf.int = TRUE) |>
  mutate(across(where(is.numeric) & !p.value, ~ round(., 3))) |>
  mutate(p.value = format.pval(p.value, digits = 3))

# Print tidy summary table
print(m3_tidy)

# Interpretation:
# Holding all other variables constant, a one-unit increase in Age is associated
#   with a 0.421 mmHg increase in systolic BP
#   (95% CI: [0.398, 0.444], p < 2e-16)
# Holding all other variables constant, a one-unit increase in BMI is associated
#   with a 0.253 mmHg increase in systolic BP
#   (95% CI: [0.192, 0.313], p = 3.09e-16)
# Males have, on average, 4.81 mmHg higher systolic BP than females of the same
#   age and BMI
#   (95% CI: [4.00 , 5.63], p < 2e-16)

#==================================================
# 5. Check model assumptions
#==================================================

# Create 4-panel assumption plot
png("./week02/day06/output/assumption_plots.png",
  width = 1400, height = 1200, res = 150
)
par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))
plot(m3)
dev.off()

# Interpretation:
# Residuals vs Fitted plot shows that points scattered quite randomly around
#   the horizontal zero line, no funnel shape, no curve
#   => Linearity and homoscedasticity assumptions are fulfilled
# Normal Q-Q plot shows that points follow the diagonal line in the middle
#   However, points largely break away from the line at the top right
#   it might indicate that the normal model does not accurately describe the
#   heavy tail (right-skewed) of data
#   => Normality assumption might not be fulfilled
# Scale-Location plot shows that red line is roughly horizontal across the plot
#   and points spread quite evenly
#   => Homoscedasticity assumption is fulfilled
# Residuals vs Leverage plot shows that there is no points outside
#   Cook's distance lines
#   => There are no influential observations

#==================================================
# 6. Coefficient plot
#==================================================

m3_tidy |>
  filter(term != "(Intercept)") |>  # Remove the row of the intercept
  mutate(term = recode(term,
    "Age"        = "Age (per year)",
    "Gendermale" = "Gender: Male vs Female",
    "BMI"        = "BMI (per kg/m²)"
  )) |>
  ggplot(aes(x = estimate, y = term)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), orientation = "y",
                height = 0.2, linewidth = 0.8, color = "steelblue") +
  geom_point(size = 3, color = "steelblue") +
  geom_text(aes(label = paste0("β = ", estimate, "\n95% CI [",
      conf.low, ", ", conf.high, "]"
    )), hjust = -0.1, size = 3, color = "grey30"
  ) +
  labs(
    title   = "Regression coefficients — predictors of systolic blood pressure",
    subtitle = "Model 3: BPSysAve ~ Age + Gender + BMI | NHANES adults",
    x        = "Coefficient estimate (mmHg)",
    y        = NULL
  ) +
  theme_minimal() +
  xlim(min(m3_tidy$conf.low[m3_tidy$term != "(Intercept)"], na.rm = TRUE) - 1,
       max(m3_tidy$conf.high[m3_tidy$term != "(Intercept)"], na.rm = TRUE) + 3)

# Save the plot
ggsave("./week02/day06/output/coefficient_plot.png",
  width = 9, height = 4, dpi = 150
)


#==================================================
# 7. Partial effects plot
#==================================================

# Create a prediction grid for Age (holding BMI at median, Gender = female)
age_grid <- data.frame(
  Age    = seq(min(nhanes$Age), max(nhanes$Age), length.out = 100),
  BMI    = median(nhanes$BMI),
  Gender = factor("female", levels = c("female", "male"))
)


age_pred <- predict(m3, newdata = age_grid, interval = "confidence") |>
  as.data.frame() |>
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

bmi_pred <- predict(m3, newdata = bmi_grid, interval = "confidence") |>
  as.data.frame() |>
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

ggsave("./week02/day06/output/partial_effects.png",
       p_partial_age | p_partial_bmi,
       width = 11, height = 4.5, dpi = 150)


#==================================================
# 8. Publication-ready regression table
#==================================================

tbl_regression(m3,
  label = list(
    Age        ~ "Age (years)",
    Gender     ~ "Gender",
    BMI        ~ "BMI (kg/m²)"
  )
) |>
  add_glance_source_note(
    label = list(r.squared ~ "R²", adj.r.squared ~ "Adjusted R²"),
    include = c(r.squared, adj.r.squared, nobs)
  ) |>
  bold_p(t = 0.05) |>
  bold_labels()


#==================================================
# Bonus: Add a quadratic term
#==================================================

# Create a column of the quadratic term of Age
nhanes <- nhanes |> mutate(Age2 = Age^2)

# Model 4: Age + Gender + BMI + Age²
m4 <- lm(BPSysAve ~ Age + Age2 + Gender + BMI, data = nhanes)

# Compare M3 vs M4 with a likelihood ratio test
anova(m3, m4)
