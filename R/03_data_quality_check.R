
# =========================================================
# Step 4: Data Quality Assessment
# =========================================================

library(tidyverse)

# Load the generated dataset
climate_health <- read_csv(
  "data/raw/climate_health_synthetic.csv",
  show_col_types = FALSE
)

# 1. Check dimensions
cat("Number of rows:", nrow(climate_health), "\n")
cat("Number of columns:", ncol(climate_health), "\n")

# 2. Inspect data structure
str(climate_health)

# 3. Check missing values
missing_values <- climate_health %>%
  summarise(
    across(everything(), ~ sum(is.na(.x)))
  )

print(missing_values)

# 4. Check duplicate records
duplicate_count <- climate_health %>%
  count(date, region) %>%
  filter(n > 1) %>%
  nrow()

cat("Duplicate date-region records:", duplicate_count, "\n")

# 5. Check valid temperature ranges
temperature_check <- climate_health %>%
  summarise(
    min_mean_temp = min(mean_temp, na.rm = TRUE),
    max_mean_temp = max(mean_temp, na.rm = TRUE),
    min_humidity = min(humidity, na.rm = TRUE),
    max_humidity = max(humidity, na.rm = TRUE),
    min_rainfall = min(rainfall, na.rm = TRUE)
  )

print(temperature_check)

# 6. Check impossible or invalid values
invalid_records <- climate_health %>%
  filter(
    min_temp > mean_temp |
      mean_temp > max_temp |
      humidity < 0 | humidity > 100 |
      rainfall < 0 |
      cardiovascular_cases < 0 |
      respiratory_cases < 0 |
      population <= 0
  )

cat("Invalid records:", nrow(invalid_records), "\n")

# 7. Save a quality report
dir.create("outputs/tables", recursive = TRUE,
           showWarnings = FALSE)

write_csv(
  missing_values,
  "outputs/tables/missing_values_report.csv"
)

cat("\nData quality assessment completed.\n")
