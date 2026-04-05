#============================================================
# Task 001 — Lung Cancer Dataset: Initial EDA
# Dataset: lung (survival package)
# Author: [T.V.Q]
# Date: [31 March 2026]
# ============================================================


# 2.1 Load and inspect the "lung" dataset
# Load the libraries
library(survival)
library(dplyr)
library(readr)
library(ggplot2)


# Inspect the structure
# Number of rows and columns
dim(lung)

# Name of variables and their data types
str(lung)

# Preview the first 6 rows
head(lung)

# 2.2 Descriptive statistics
# Compute mean, median, SD, min, max of variable "time"
mean_time <- round(mean(lung$time, na.rm = TRUE), 1)
median_time <- round(median(lung$time, na.rm = TRUE), 1)
sd_time <- round(sd(lung$time, na.rm = TRUE), 1)
min_time <- min(lung$time, na.rm = TRUE)
max_time <- max(lung$time, na.rm = TRUE)

# Print the results of variable "time"
cat("Variable: time\n",
  "Mean   :", mean_time, "\n",
  "Median :", median_time, "\n",
  "SD     :", sd_time, "\n",
  "Min    :", min_time, "\n",
  "Max    :", max_time, "\n"
)

# Compute mean, median, SD, min, max of variable "age"
mean_age <- round(mean(lung$age, na.rm = TRUE), 1)
median_age <- round(median(lung$age, na.rm = TRUE), 1)
sd_age <- round(sd(lung$age, na.rm = TRUE), 1)
min_age <- min(lung$age, na.rm = TRUE)
max_age <- max(lung$age, na.rm = TRUE)

# Print the results of variable "age"
cat("Variable: age\n",
  "Mean   :", mean_age, "\n",
  "Median :", median_age, "\n",
  "SD     :", sd_age, "\n",
  "Min    :", min_age, "\n",
  "Max    :", max_age, "\n",
  sep = " "
)

# Compute count by group of variable "status"
count_status <- table(lung$status)

# Compute percentage by group of variable "status"
percent_status <- round(prop.table(count_status) * 100, 1)

# Print the results of variable "status"
cat("Variable   : status\n",
  "Censored   :", "\n",
  " Count     : ", count_status[1], "\n",
  " Percentage: ", percent_status[1], "%\n",
  "Dead       :", "\n",
  " Count     : ", count_status[2], "\n",
  " Percentage: ", percent_status[2], "%\n"
)


# Compute count by group of variable "sex"
count_sex <- table(lung$sex)

# Compute percentage by group of variable "sex"
percent_sex <- round(prop.table(count_sex) * 100, 1)

# Print the results of variable "sex"
cat("Variable    : sex\n",
  "Male       :", "\n",
  " Count     : ", count_sex[1], "\n",
  " Percentage: ", percent_sex[1], "%\n",
  "Female     :", "\n",
  " Count     : ", count_sex[2], "\n",
  " Percentage: ", percent_sex[2], "%\n"
)

# Do loop to count missing values for each column
# Do loop to calculate the missing percentage for each column
# Do loop to print warning message if more than 10% of values are missing
for (i in 2:ncol(lung)){
  count_na <- sum(is.na(lung[i]))
  percent_na <- round((count_na / nrow(lung)) * 100, 2)
  cat("There are", count_na, "missing values (", percent_na, "% ) in column",
    colnames(lung)[i], "\n"
  )
  if (percent_na > 10) {
    cat("Warning: More than 10% of observations are missing in column",
      colnames(lung)[i], "\n"
    )
  }
}

# Select only numeric variables from lung dataset
lung_numvar <- select(lung, -c(status, sex, ph.ecog))

# Create an empty dataset
summary_table <- data.frame(variable = character(0),
  mean = numeric(0),
  median = numeric(0),
  sd = numeric(0),
  min = numeric(0),
  max = numeric(0),
  n_missing = numeric(0)
)

# Do loop to create summary of numeric variables from lung dataset
for (i in 2:ncol(lung_numvar)){
  new_row <- lung_numvar |>
    summarise(
      variable = colnames(lung_numvar)[i],
      mean = round(mean(lung_numvar[[i]], na.rm = TRUE), 2),
      median = round(median(lung_numvar[[i]], na.rm = TRUE), 2),
      sd = round(sd(lung_numvar[[i]], na.rm = TRUE), 2),
      min = round(min(lung_numvar[[i]], na.rm = TRUE), 2),
      max = round(max(lung_numvar[[i]], na.rm = TRUE), 2),
      n_missing = round(sum(is.na(lung_numvar[i])), 2)
    )
  summary_table <- rbind(summary_table, new_row)
}

# Write summary CSV to the "output" folder
write_csv(summary_table, "./week01/day01/output/summary_table.csv")


# histogram of time and status

lung |>
  mutate(status_label = ifelse(status == 1, "Censored", "Dead")) |>
  ggplot(aes(x = time, fill = status_label)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  labs(
    title = "Distribution of Survival Time",
    x = "Time (days)",
    y = "Count",
    fill = "Status"
  ) +
  theme_minimal()

ggsave("./week01/day01/output/survival_time_hist.png",
       width = 8, height = 5, dpi = 150)
