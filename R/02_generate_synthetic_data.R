
# =========================================================
# Climate and Health Epidemiology
# Step 3: Generate synthetic data
# Fictional data for training only
# =========================================================

library(tidyverse)

set.seed(2026)

# Study period
dates <- seq(
  as.Date("2018-01-01"),
  as.Date("2026-03-19"),
  by = "day"
)

regions <- c(
  "Region_A", "Region_B", "Region_C",
  "Region_D", "Region_E"
)

# Create one record per region per day
climate_health <- expand_grid(
  date = dates,
  region = regions
) %>%
  mutate(
    year = as.integer(format(date, "%Y")),
    month = as.integer(format(date, "%m")),
    
    seasonal_temp = 29 +
      8 * sin(2 * pi * (month - 4) / 12),
    
    mean_temp = round(
      seasonal_temp + rnorm(n(), 0, 3), 1
    ),
    
    max_temp = round(
      mean_temp + runif(n(), 2, 7), 1
    ),
    
    min_temp = round(
      mean_temp - runif(n(), 2, 7), 1
    ),
    
    humidity = round(
      pmin(pmax(rnorm(n(), 55, 15), 15), 100), 1
    ),
    
    rainfall = round(
      if_else(
        runif(n()) < 0.30,
        rgamma(n(), shape = 2, scale = 8),
        0
      ), 1
    ),
    
    population = case_when(
      region == "Region_A" ~ 500000,
      region == "Region_B" ~ 350000,
      region == "Region_C" ~ 250000,
      region == "Region_D" ~ 180000,
      TRUE ~ 120000
    ),
    
    cardiovascular_cases = rpois(
      n(),
      lambda = population / 10000 *
        exp(0.012 * (mean_temp - 29))
    ),
    
    respiratory_cases = rpois(
      n(),
      lambda = population / 10000 *
        exp(0.008 * (mean_temp - 29))
    )
  ) %>%
  select(
    date, region, year, month,
    mean_temp, max_temp, min_temp,
    humidity, rainfall, population,
    cardiovascular_cases, respiratory_cases
  )

# Inspect the data
print(dim(climate_health))
print(head(climate_health, 10))
summary(climate_health)

# Create output folder
dir.create(
  "data/raw",
  recursive = TRUE,
  showWarnings = FALSE
)

# Export as CSV
write_csv(
  climate_health,
  "data/raw/climate_health_synthetic.csv"
)

cat("\nDataset created successfully!\n")
cat("Rows:", nrow(climate_health), "\n")
cat("Columns:", ncol(climate_health), "\n")
