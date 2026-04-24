#============================================================
# Task 003 — Descriptive Statistics
# Dataset: NHANES (NHANES package)
# Author: [T.V.Q]
# Date: [15 April 2026]
# ============================================================

# Load the libraries
library(NHANES) ## For NHANES dataset
library(dplyr)
library(ggplot2)
library(moments)
library(tidyr) ## To reshape dataset into long format

#=== 2.1 Examine the NHANES dataset ===#

# Examine the structure of NHANES dataset
str(NHANES)

# Filter adult participants (age ≥ 18)
nhanes_adult <- NHANES |>
  filter(Age >= 18) |>
  distinct() ## select non-duplicated rows only

## the symbol |> or %>% is the pipe operator is used to chain functions together
## the term on the left of |> is treated as the input of the term on the right

## the above chain can be described as:
### from the NHANES dataset, filter out rows with Age >= 18
### then from the filtered rows, select the non-duplicated rows only

# Print the number of observations in the new dataset
cat("There are", nrow(nhanes_adult), "rows in the filtered dataset", "\n")

#=== 2.2 Write a reusable summary function ===#

# Summary function
describe_numeric <- function(x, varname = "variable") {
  ## function with 2 inputs: x and varname
  ### varname = "variable" means that the varname input is optional
  ### and if varname is not defined, it will take the default value "variable"
  x_clean <- x[!is.na(x)] ## remove missing observations
  ### input data should be vector
  q1  <- quantile(x_clean, 0.25)
  q3  <- quantile(x_clean, 0.75)
  iqr <- q3 - q1
  shapiro_result <- shapiro.test(x_clean[1:5000])

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
    n_outliers = sum(x_clean < (q1 - 1.5 * iqr) | x_clean > (q3 + 1.5 * iqr)),
    ## the function sum(x < a | x > b) counts the number of elements in vector x
    ### that are either less than a OR greater than b
    ### the expression x < a | x > b creates a logical vector of TRUE or FALSE
    ### when put the logical vector in the sum() function,
    ### values of TRUE and FALSE are turned into 1 and 0
    ### the sum then is equal to the number of TRUE values
    shapiro_W   = round(shapiro_result$statistic, 5),
    shapiro_p   = shapiro_result$p.value
  )
}

#=== 2.3 Apply the function to key variables ===#

# For BMI
row1 <- describe_numeric(nhanes_adult$BMI, "BMI")

# For Age
row2 <- describe_numeric(nhanes_adult$Age, "Age")

# For BPSysAve
row3 <- describe_numeric(nhanes_adult$BPSysAve,
  "Combined Systolic blood pressure"
)

# For BPDiaAve
row4 <- describe_numeric(nhanes_adult$BPDiaAve,
  "Combined Diastolic blood pressure"
)

# For TotChol
row5 <- describe_numeric(nhanes_adult$TotChol, "Total HDL cholesterol")

# Combine all summaries into one dataframe
summary_table <- bind_rows(
  row1, row2, row3, row4, row5
)

# Export the summary table in CSV format
write.csv(summary_table, "./week01/day03/output/nhanes_summary.csv",
          row.names = FALSE)

# Print the summary table
print(summary_table)

#=== 2.4 Create side-by-side boxplots of key variables across gender ===#

# Reshape the dataset to long format
nhanes_long <- nhanes_adult |>
  select(Gender, BMI, Age, BPSysAve, BPDiaAve, TotChol) |> ## select only
  ### 5 key variables and Gender
  pivot_longer(cols = -Gender, names_to = "variable", values_to = "value") |>
  ## pivot_longer() is used to turn the wide format into long format
  ### cols = -Gender means selecting all columns except for Gender
  ### names_to = "variable" means putting all names of selected columns
  ### into a new column called "variable"
  ### values_to = "value" means putting all values of selected columns
  ### into a new column called "value"
  filter(!is.na(value), !is.na(Gender))

# Plot the boxplots
p_box <- ggplot(nhanes_long, aes(x = Gender, y = value, fill = Gender)) +
  geom_boxplot(outlier.size = 0.8, outlier.alpha = 0.4, outlier.color = "red") +
  ## outlier.size and outlier.alpha are used to highlight outliers
  ### outlier.size controls the size of outliers (value > 0)
  ### outlier.alpha controls the transparency of outliers
  ### (value between 0 and 1)
  facet_wrap(~variable, scales = "free_y") + ## facet_wrap() splits a plot
  ### into multiple plots based on a categorical variable
  ### the chosen variable here is the column name "variable"
  ### scales = "free_y" means that each plot uses its own y-axis
  labs(title = "Distribution of key health indicators by gender — NHANES",
       x = NULL, y = "Value") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Export the figure
ggsave("./week01/day03/output/boxplots_by_gender.png", p_box,
  width = 10, height = 6, dpi = 150
)

#=== 2.5 Create scatter plot beween BMI and Age ===#

# Filter the dataset without missing value in BMI, Age, and Gender columns
nhanes_bmi <- nhanes_adult |>
  filter(!is.na(BMI), !is.na(Age), !is.na(Gender))

# Plot the scatter plot
p_scatter <- ggplot(nhanes_bmi, aes(x = Age, y = BMI, color = Gender)) +
  geom_point(alpha = 0.3, size = 0.8) +
  geom_smooth(method = "loess", se = TRUE, linewidth = 1.2) +
  ## method = "loess" means that smoothing line uses LOESS method
  ### Locally Estimated Scatterplot Smoothing
  ### se = TRUE means displaying the confidence band
  labs(title = "BMI vs age by gender — NHANES adults",
       x = "Age (years)", y = "BMI (kg/m²)") +
  theme_minimal()

# Export the figure
ggsave("./week01/day03/output/bmi_age_scatter.png",
  width = 8, height = 5, dpi = 150
)
