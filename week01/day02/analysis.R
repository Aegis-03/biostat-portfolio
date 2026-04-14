#============================================================
# Task 002 — Lung Cancer Dataset: Initial EDA
# Dataset: lung (survival package)
# Author: [T.V.Q]
# Date: [14 April 2026]
# ============================================================

# Load the libraries
library(ggplot2)
library(moments) ## To calculate skewness of distribution
library(patchwork) ## To combine multiple plots into a single layout
library(survival) ## To use "lung" dataset
library(fitdistrplus) ## To fit Weibull distribution


#=== 2.1 Simulate 3 distributions ===#

# Set the seed for reproducibility
## After the seed is set, the functions that generate random numbers
## will produce the same result after each run
set.seed(42)

# Set the sample size
n <- 1000

# Generate a dataframe of a normal distribution with mean of 300 and sd of 150
x1 <- data.frame(sim_val = rnorm(n, mean = 300, sd = 150))

# Mean, median, SD, and skewness of the generated normal distribution
cat("Summary of generated Normal distribution:", "\n",
  "Mean    :", round(mean(x1$sim_val, na.rm = TRUE), 1), "\n",
  "Median  :", round(median(x1$sim_val, na.rm = TRUE), 1), "\n",
  "SD      :", round(sd(x1$sim_val, na.rm = TRUE), 1), "\n",
  "Skewness:", round(skewness(x1$sim_val, na.rm = TRUE), 1), "\n"
)

# Generate an exponential distribution with rate of 1/300
x2 <-  data.frame(sim_val = rexp(n, rate = 1 / 300))

# Mean, median, SD, and skewness of the generated exponential distribution
cat("Summary of generated Exponential distribution:", "\n",
  "Mean    :", round(mean(x2$sim_val, na.rm = TRUE), 1), "\n",
  "Median  :", round(median(x2$sim_val, na.rm = TRUE), 1), "\n",
  "SD      :", round(sd(x2$sim_val, na.rm = TRUE), 1), "\n",
  "Skewness:", round(skewness(x2$sim_val, na.rm = TRUE), 1), "\n"
)

# Generate an uniform distribution on interval (0, 1000)
x3 <- data.frame(sim_val = runif(n, min = 0, max = 1000))

# Mean, median, SD, and skewness of the generated uniform distribution
cat("Summary of generated Uniform distribution:", "\n",
  "Mean    :", round(mean(x3$sim_val, na.rm = TRUE), 1), "\n",
  "Median  :", round(median(x3$sim_val, na.rm = TRUE), 1), "\n",
  "SD      :", round(sd(x3$sim_val, na.rm = TRUE), 1), "\n",
  "Skewness:", round(skewness(x3$sim_val, na.rm = TRUE), 1), "\n"
)

#=== 2.2 Plot 3 generated distribution ===#

# Histogram of normal distribution
p1 <- ggplot(x1, aes(x = sim_val)) +
  geom_histogram(fill = "white", color = "black", bins = 30) +
  labs(title = "Histogram of Normal Distribution") +
  xlab("Simulated value") +
  ylab("Count") +
  geom_vline(xintercept = mean(x1$sim_val),
             color = "red", linetype = "dashed", linewidth = 2) +
  theme_minimal()

# Histogram of exponential distribution
p2 <- ggplot(x2, aes(x = sim_val)) +
  geom_histogram(fill = "skyblue", color = "black", bins = 30) +
  labs(title = "Histogram of Exponential Distribution") +
  xlab("Simulated value") +
  ylab("Count") +
  geom_vline(xintercept = mean(x2$sim_val),
             color = "red", linetype = "dashed", linewidth = 2) +
  theme_minimal()

# Histogram of uniform distribution
p3 <- ggplot(x3, aes(x = sim_val)) +
  geom_histogram(fill = "lightgreen", color = "black", bins = 30) +
  labs(title = "Histogram of Uniform Distribution",
       x = "Simulated value", y = "Count") +
  geom_vline(xintercept = mean(x3$sim_val),
             color = "red", linetype = "dashed", linewidth = 2) +
  theme_minimal()

# Combine 3 plots into one figure
combined_plot <- p1 + p2 + p3
ggsave("./week01/day02/output/distributions_overview.png",
       combined_plot, width = 12, height = 4, dpi = 300)


#=== 2.3 Overlay theoretical curve ===#

#  Extract the "time" variable into a a vector
## and remove the missing values (NA)
time_clean_vec <- lung$time[!is.na(lung$time)]

# Create a dataframe from the vector
time_clean <- data.frame(time = time_clean_vec)

# Plot the histogram of "time" with 2 theoretical curves
p_time <- ggplot(time_clean, aes(x = time)) +
  geom_histogram(aes(y = after_stat(density)),
                 fill = "lightgrey", color = "black") +
  ## fitted normal density curve
  stat_function(fun = dnorm,
                args = list(mean = mean(time_clean$time),
                            sd = sd(time_clean$time)),
                color = "red", linewidth = 1, linetype = "solid") +
  ## fitted exponential density curve
  stat_function(fun = dexp,
                args = list(rate = 1 / mean(time_clean$time)),
                color = "blue", linewidth = 1, linetype = "dashed") +
  labs(title = "Empirical vs theoretical distributions — lung survival time",
       subtitle = "Red = Normal fit  |  Blue dashed = Exponential fit",
       x = "Survival time (days)", y = "density") +
  theme_minimal()

# Export the histogram with fitted curves
ggsave("./week01/day02/output/empirical_vs_theoretical.png",
       p_time, width = 12, height = 6, dpi = 300)

#=== 2.4 QQ plots ===#

# QQ plot against theoretical exponential distribution
qq_expo <- ggplot(time_clean, aes(sample = time)) +
  ## QQ plot to compare survival time against a theoretical
  ## exponential distribution with rate of 1/mean(time)
  stat_qq(distribution = qexp,
          dparams = list(rate = 1 / mean(time_clean$time))) +
  ## add a reference line to QQ plot of exponential distribution
  ## with rate of 1/mean(time)
  stat_qq_line(distribution = qexp,
               dparams = list(rate = 1 / mean(time_clean$time)),
               col = "red") +
  labs(title = "Exponential Q-Q Plot — lung survival time",
       x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_minimal()

# QQ plot against theoretical normal distribution
qq_norm <- ggplot(time_clean, aes(sample = time)) +
  ## QQ plot to compare survival time against a theoretical
  ## normal distribution with mean and sd
  stat_qq(distribution = qnorm,
          dparams = list(mean = mean(time_clean$time),
                         sd = sd(time_clean$time))) +
  ## add a reference line to QQ plot of normal distribution
  ## with mean and sd
  stat_qq_line(distribution = qnorm,
               dparams = list(mean = mean(time_clean$time),
                              sd = sd(time_clean$time)),
               col = "red") +
  labs(title = "Normal Q-Q Plot — lung survival time",
       x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_minimal()

# Combine 2 QQ plots into one figure
combined_qq <- qq_norm + qq_expo
ggsave("./week01/day02/output/qq_plot.png",
       combined_qq, width = 12, height = 6, dpi = 300)


#=== 2.5 Bonus ===#

# Fit the weibull distribution
fit_weibull <- fitdist(time_clean_vec, "weibull")

# Summary of the fitted weibull distribution
print(summary(fit_weibull))

# Save the plotted weibull distribution
png("./week01/day02/output/weibull_plot.png")
plot(fit_weibull)
dev.off()
