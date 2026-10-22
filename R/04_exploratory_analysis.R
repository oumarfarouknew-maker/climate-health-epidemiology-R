
# ============================================================
# Climate and Health Epidemiology
# Step 5: Exploratory Data Analysis (EDA)
# Synthetic data — training purposes only
# ============================================================

library(tidyverse)

# Load dataset
climate_health <- read_csv(
  "data/raw/climate_health_synthetic.csv",
  show_col_types = FALSE
)

# Convert date to Date format
climate_health <- climate_health %>%
  mutate(date = as.Date(date))

# 1. Basic dataset overview
cat("Number of records:", nrow(climate_health), "\n")
cat("Number of variables:", ncol(climate_health), "\n")
cat("Study period:",
    min(climate_health$date), "to",
    max(climate_health$date), "\n")

# 2. Summary statistics
summary_stats <- climate_health %>%
  summarise(
    mean_temperature = mean(mean_temp, na.rm = TRUE),
    sd_temperature = sd(mean_temp, na.rm = TRUE),
    mean_humidity = mean(humidity, na.rm = TRUE),
    mean_rainfall = mean(rainfall, na.rm = TRUE),
    mean_cardiovascular_cases =
      mean(cardiovascular_cases, na.rm = TRUE),
    mean_respiratory_cases =
      mean(respiratory_cases, na.rm = TRUE)
  )

print(summary_stats)

# 3. Temperature distribution
p1 <- ggplot(climate_health, aes(x = mean_temp)) +
  geom_histogram(bins = 40) +
  labs(
    title = "Distribution of Mean Daily Temperature",
    subtitle = "Synthetic data for training",
    x = "Mean temperature (°C)",
    y = "Number of observations"
  ) +
  theme_minimal()

print(p1)

# 4. Daily temperature trend
daily_temperature <- climate_health %>%
  group_by(date) %>%
  summarise(
    mean_temperature = mean(mean_temp),
    .groups = "drop"
  )

p2 <- ggplot(
  daily_temperature,
  aes(x = date, y = mean_temperature)
) +
  geom_line() +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Daily Mean Temperature Over Time",
    subtitle = "Average across five fictional regions",
    x = "Date",
    y = "Mean temperature (°C)"
  ) +
  theme_minimal()

print(p2)

# 5. Health outcomes by region
regional_summary <- climate_health %>%
  group_by(region) %>%
  summarise(
    cardiovascular_cases =
      sum(cardiovascular_cases, na.rm = TRUE),
    respiratory_cases =
      sum(respiratory_cases, na.rm = TRUE),
    average_temperature =
      mean(mean_temp, na.rm = TRUE),
    .groups = "drop"
  )

print(regional_summary)

p3 <- ggplot(
  regional_summary,
  aes(x = region, y = cardiovascular_cases)
) +
  geom_col() +
  labs(
    title = "Total Simulated Cardiovascular Cases by Region",
    x = "Fictional region",
    y = "Total cases"
  ) +
  theme_minimal()

print(p3)

# 6. Temperature and cardiovascular cases
p4 <- ggplot(
  climate_health,
  aes(x = mean_temp, y = cardiovascular_cases)
) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Temperature and Cardiovascular Cases",
    subtitle = "Exploratory association, not causal evidence",
    x = "Mean temperature (°C)",
    y = "Simulated cardiovascular cases"
  ) +
  theme_minimal()

print(p4)

# 7. Temperature and respiratory cases
p5 <- ggplot(
  climate_health,
  aes(x = mean_temp, y = respiratory_cases)
) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Temperature and Respiratory Cases",
    subtitle = "Exploratory association, not causal evidence",
    x = "Mean temperature (°C)",
    y = "Simulated respiratory cases"
  ) +
  theme_minimal()

print(p5)

# 8. Monthly patterns
monthly_summary <- climate_health %>%
  group_by(month) %>%
  summarise(
    mean_temperature = mean(mean_temp, na.rm = TRUE),
    mean_cardiovascular_cases =
      mean(cardiovascular_cases, na.rm = TRUE),
    mean_respiratory_cases =
      mean(respiratory_cases, na.rm = TRUE),
    .groups = "drop"
  )

print(monthly_summary)

p6 <- ggplot(
  monthly_summary,
  aes(x = month, y = mean_temperature)
) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = 1:12) +
  labs(
    title = "Average Temperature by Month",
    x = "Month",
    y = "Mean temperature (°C)"
  ) +
  theme_minimal()

print(p6)

# 9. Save summary tables and figures
dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "outputs/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  summary_stats,
  "outputs/tables/eda_summary_statistics.csv"
)

write_csv(
  regional_summary,
  "outputs/tables/regional_health_summary.csv"
)

write_csv(
  monthly_summary,
  "outputs/tables/monthly_summary.csv"
)

ggsave(
  "outputs/figures/temperature_distribution.png",
  p1, width = 9, height = 6, dpi = 300
)

ggsave(
  "outputs/figures/temperature_trend.png",
  p2, width = 10, height = 6, dpi = 300
)

ggsave(
  "outputs/figures/cardiovascular_by_region.png",
  p3, width = 9, height = 6, dpi = 300
)

ggsave(
  "outputs/figures/temperature_cardiovascular.png",
  p4, width = 9, height = 6, dpi = 300
)

ggsave(
  "outputs/figures/temperature_respiratory.png",
  p5, width = 9, height = 6, dpi = 300
)

ggsave(
  "outputs/figures/monthly_temperature.png",
  p6, width = 9, height = 6, dpi = 300
)

cat("\nEDA completed successfully.\n")
cat("Summary tables saved in outputs/tables/.\n")
cat("Figures saved in outputs/figures/.\n")
