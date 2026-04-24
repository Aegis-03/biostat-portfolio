#============================================================
# Task 005 — Hypothesis Testing
# Dataset: NHANES (NHANES package)
# Author: [T.V.Q]
# Date: [23 April 2026]
# ============================================================

# Load the library
library(NHANES) ## For NHANES dataset
library(dplyr) ## For data manipulation
library(ggplot2) ## For graphs
library(moments) ## For skewness() function
library(patchwork) ## To combine multiple plots into a single layout

#=== 2.1 Prepare NHANES dataset ===#

# Filter the adult population from NHANES dataset
## remove all duplicate rows
nhanes_adult <- NHANES |>
  filter(Age >= 18) |>
  distinct()

# Print the missing-value counts of target variables
cat("Number of missing data:", "\n",
  "Average Systolic BP   :", sum(is.na(nhanes_adult$BPSysAve)), "\n",
  "BMI                   :", sum(is.na(nhanes_adult$BMI)), "\n",
  "Gender                :", sum(is.na(nhanes_adult$Gender)), "\n",
  "Diabetes status       :", sum(is.na(nhanes_adult$Diabetes)), "\n",
  "Current Smoking status:", sum(is.na(nhanes_adult$SmokeNow)), "\n"
)

#=== 2.2 Independent samples t-test ===#

# Step 1 — State hypotheses and Significant level
## H0: mean of the Average Systolic BP is equal in males and females
## H1: mean of the Average Systolic BP differs between males and females
## Significance level: alpha = 0.05 (two-sided)


# Step 2 — Check the normality assumption

## Remove rows with missing data
bp_data <- nhanes_adult |>
  filter(!is.na(BPSysAve), !is.na(Gender))

## Check the normality of Average Systolic BP in each gender
print(shapiro.test(
  sample(bp_data$BPSysAve[bp_data$Gender == "male"],
    min(5000, length(bp_data$BPSysAve[bp_data$Gender == "male"]))
  )
))

print(shapiro.test(
  sample(bp_data$BPSysAve[bp_data$Gender == "female"],
    min(5000, length(bp_data$BPSysAve[bp_data$Gender == "female"]))
  )
))

# Step 3 Visualize both groups

## Create density curves of Average Systolic BP by gender
p1 <- ggplot(bp_data, aes(x = BPSysAve, fill = Gender, color = Gender)) +
  geom_density(alpha = 0.35, linewidth = 0.8) +
  geom_vline(
    data = bp_data |>
      group_by(Gender) |>
      summarise(m = mean(BPSysAve)), ### create a dataset of the means
    aes(xintercept = m, color = Gender), linetype = "dashed"
  ) +
  labs(title = "Average Systolic BP distribution by gender",
       x = "Average Systolic BP (mmHg)", y = "Density") +
  theme_minimal()

## Create Q-Q plots of Average Systolic BP by gender
p2 <- ggplot(bp_data, aes(sample = BPSysAve, color = Gender)) +
  ### "sample =" is a specialized aesthetic mapping for Q-Q plot
  stat_qq() + stat_qq_line() +
  facet_wrap(~Gender) +
  labs(title = "Q-Q plots — Average Systolic BP by gender",
       x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_minimal()

## Save the plot
ggsave("./week02/day05/output/bp_by_gender_test.png",
  p1 / p2, width = 9, height = 8, dpi = 150
)

# Step 4 - Run t-test of Average Systolic BP between genders
## Variances are assumed to be unequal => Welch’s t-test
t_result <- t.test(BPSysAve ~ Gender, data = bp_data, var.equal = FALSE)

## Print the whole Welch’s t-test output
print(t_result)

# Step 5 -  Extract and print key values from Welch’s t-test output
cat("Summary of t-test of Average Systolic BP between genders", "\n",
  "t-statistic        :", round(t_result$statistic, 3), "\n",
  "Degrees of freedom :", round(t_result$parameter, 1), "\n",
  ## specialized formar for p-values
  "p-value            :", format.pval(t_result$p.value, digits = 3), "\n",
  "Mean BP — Male     :", round(t_result$estimate[1], 2), "mmHg\n",
  "Mean BP — Female   :", round(t_result$estimate[2], 2), "mmHg\n",
  "95% CI for difference in means: [",
  round(t_result$conf.int[1], 2), ",", round(t_result$conf.int[2], 2), "]\n"
)

# Step 6 - Compute Cohen's size effect

## Calculate pooled SD
n1        <- sum(bp_data$Gender == "male")
n2        <- sum(bp_data$Gender == "female")
sd1       <- sd(bp_data$BPSysAve[bp_data$Gender == "male"])
sd2       <- sd(bp_data$BPSysAve[bp_data$Gender == "female"])
pooled_sd <- sqrt(((n1 - 1) * sd1^2 + (n2 - 1) * sd2^2) / (n1 + n2 - 2))

## Calculate Cohen's size effect
cohens_d <- abs(diff(t_result$estimate)) / pooled_sd
### diff() function compute lagged differences between elements
### in a numeric vector/matrix

## Print the interpretation of Cohen's size effect
cat("Cohen's d:", round(cohens_d, 3), "—",
  ifelse(cohens_d < 0.2, "negligible",
    ifelse(cohens_d < 0.5, "small",
      ifelse(cohens_d < 0.8, "medium", "large")
    )
  ), "effect\n"
)

#=== 2.3 Wilcoxon rank-sum test ===#

# Step 1 — Check the normality assumption

## Remove rows with missing data
bmi_data <- nhanes_adult |> filter(!is.na(BMI), !is.na(Gender))

## Examine the skewness of the distribution of BMI by gender
cat("Skewness — Male BMI:  ",
  round(skewness(bmi_data$BMI[bmi_data$Gender == "male"]), 3), "\n"
)
cat("Skewness — Female BMI:",
  round(skewness(bmi_data$BMI[bmi_data$Gender == "female"]), 3), "\n"
)

# Step 2 — Visualize both groups

## Create histograms of BMI of male

### Filter male data
bmi_data_male <- bmi_data |>
  filter(Gender == "male")

### Create histograms
p_hist_m <- ggplot(bmi_data_male, aes(x = BMI)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, fill = "skyblue",
                 color = "black") +
  stat_function(fun = dnorm,
    args = list(mean = mean(bmi_data_male$BMI),
                sd = sd(bmi_data_male$BMI)),
    colour = "red"
  ) +
  labs(title = "BMI distribution of male",
       x = "BMI (kg/m2)", y = "Density") +
  theme_minimal()

## Create histograms of BMI of female

### Filter male data
bmi_data_female <- bmi_data |>
  filter(Gender == "female")

### Create histograms
p_hist_f <- ggplot(bmi_data_female, aes(x = BMI)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, fill = "pink1",
                 color = "black") +
  stat_function(fun = dnorm,
    args = list(mean = mean(bmi_data_female$BMI),
                sd = sd(bmi_data_female$BMI)),
    colour = "red"
  ) +
  labs(title = "BMI distribution of female",
       x = "BMI (kg/m2)", y = "Density") +
  theme_minimal()

## Create Q-Q plots of BMI of male
p_qq_m <- ggplot(bmi_data_male, aes(sample = BMI)) +
  stat_qq(color = "skyblue") + stat_qq_line(color = "skyblue") +
  labs(title = "Q-Q plots — BMI of male",
       x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_minimal()

## Create Q-Q plots of BMI of female
p_qq_f <- ggplot(bmi_data_female, aes(sample = BMI)) +
  stat_qq(color = "pink1") + stat_qq_line(color = "pink1") +
  labs(title = "Q-Q plots — BMI of female",
       x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_minimal()

## Save the plot
ggsave("./week02/day05/output/bmi_normality_check.png",
  (p_hist_m | p_hist_f) / (p_qq_m | p_qq_f), width = 9, height = 8, dpi = 150
)

# Step 3 — State hypotheses
## H0: BMI distribution is identical in males and females
## H1: BMI distributions differ between males and females

# Step 4 - Run Wilcoxon rank-sum test of BMI between genders
wilcox_result <- wilcox.test(BMI ~ Gender, data = bmi_data, conf.int = TRUE)
## "conf.int = TRUE" means that the confidence interval is calculated
print(wilcox_result)

# Step 5 - Extract and print key values from Wilcoxon rank-sum test output
cat("Summary of Wilcoxon rank-sum test of BMI between genders", "\n",
  "W statistic:", wilcox_result$statistic, "\n",
  "p-value    :", format.pval(wilcox_result$p.value, digits = 3), "\n",
  "95% CI for location shift: [",
  round(wilcox_result$conf.int[1], 2), ",",
  round(wilcox_result$conf.int[2], 2), "]\n"
)

# Step 6 - Print medians by gender
bmi_data |>
  group_by(Gender) |>
  summarise(
    n      = n(),
    median = median(BMI),
    iqr    = IQR(BMI)
  ) |>
  print()

#=== 2.4 Chi-squared test ===#

# Step 1 - Build the contingency table

## Remove rows with missing data
diab_smoke <- nhanes_adult |>
  filter(!is.na(Diabetes), !is.na(SmokeNow))

## Print the contingency table
cont_table <- table(Diabetes = diab_smoke$Diabetes,
  SmokeNow = diab_smoke$SmokeNow
)
print(cont_table)

## Print the row proportions — percentage smoking within each diabetes group
print(round(prop.table(cont_table, margin = 1) * 100, 1))
### "margin = 1" means calculate row proportions

# Step 2 - Visualize the grouped plot
diab_smoke |>
  count(Diabetes, SmokeNow) |> ## create a data frame for the counts of each
  ### level of combination between Diabetes and SmokeNow
  group_by(Diabetes) |>
  mutate(pct = n / sum(n) * 100) |> ## mutate() function add a column
  ### to the input data frame
  ggplot(aes(x = Diabetes, y = pct, fill = SmokeNow)) +
  geom_col(position = "dodge", width = 0.6) +
  ## position = "dodge" means that the columns are placed
  ## side-by-side (not stacked)
  geom_text(aes(label = paste0(round(pct, 1), "%")),
            position = position_dodge(width = 0.6),
            ## "width = " defines the dodge width between elements
            vjust = -0.4, size = 3.5) +
  labs(title = "Smoking prevalence by diabetes status — NHANES adults",
       x = "Diabetes status", y = "Percentage (%)",
       fill = "Currently smoking") +
  scale_fill_manual(values = c("Yes" = "#e07b5a", "No" = "#5a9ec4")) +
  ## scale_fill_manual() manually assigns specific colors to each discrete value
  theme_minimal()

## Save the plot
ggsave("./week02/day05/output/diabetes_smoking_table.png",
  width = 7, height = 5, dpi = 150
)

# Step 3 - State hypotheses
## H0: There is no association between Diabetes status and Smoking prevalence
## H1: There is an association between Diabetes status and Smoking prevalence

# Step 4 - Run the chi-squared test
chi_result <- chisq.test(cont_table)
print(chi_result)

## Extract and print key values from Wilcoxon rank-sum test output
cat("Summary of Chi-squared test between Diabetes status and Smoking status",
  "\n",
  "Chi-squared statistic:", round(chi_result$statistic, 3), "\n",
  "Degrees of freedom   :", chi_result$parameter, "\n",
  "p-value              :", format.pval(chi_result$p.value, digits = 3), "\n"
)

## Print expected cell counts
cat("\nExpected cell counts:\n")
print(round(chi_result$expected, 1))

# Step 4 — Compute Cramér's V (effect size)
n         <- sum(cont_table)
cramers_v <- sqrt(chi_result$statistic /
                    (n * (min(nrow(cont_table), ncol(cont_table)) - 1)))

cat("Cramér's V:", round(cramers_v, 3), "—",
  ifelse(cramers_v < 0.1, "negligible",
    ifelse(cramers_v < 0.3, "small",
      ifelse(cramers_v < 0.5, "medium", "large")
    )
  ), "association\n"
)


#=== Bonus: one-sample t-test ===#

# Step 1 - State hypotheses
## H0: mean BMI in NHANES adults = 25 (WHO overweight threshold)
## H1: mean BMI ≠ 25

# Step 2 - Run the one-sample t-test
bmi_one <- t.test(nhanes_adult$BMI, mu = 25, na.rm = TRUE)
print(bmi_one)

# Step 3 -  Extract and print key values from one-sample t-test output
cat("Summary of t-test of BMI and WHO overweight threshold", "\n",
  "t-statistic        :", round(bmi_one$statistic, 3), "\n",
  "Degrees of freedom :", round(bmi_one$parameter, 1), "\n",
  ## specialized formar for p-values
  "p-value            :", format.pval(bmi_one$p.value, digits = 3), "\n",
  "Mean BMI           :", round(bmi_one$estimate, 2), "kg/m2", "\n",
  "95% CI for difference in means: [",
  round(bmi_one$conf.int[1], 2), ",", round(bmi_one$conf.int[2], 2), "]\n"
)

# Step 4 - Compute Cohen's size effect

## Calculate SD
bmi_sd <- sd(nhanes_adult$BMI, na.rm = TRUE)

## Calculate Cohen's size effect
cohens_d_bmi <- abs(bmi_one$estimate - 25) / bmi_sd

## Print the interpretation of Cohen's size effect
cat("Cohen's d:", round(cohens_d_bmi, 3), "—",
  ifelse(cohens_d_bmi < 0.2, "negligible",
    ifelse(cohens_d_bmi < 0.5, "small",
      ifelse(cohens_d_bmi < 0.8, "medium", "large")
    )
  ), "effect\n"
)
