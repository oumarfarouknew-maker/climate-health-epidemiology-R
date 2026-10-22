
# ============================================================
# Step 6: Statistical Modeling
# Synthetic climate and health data — training only
# ============================================================

library(tidyverse)

# Load data
climate_health <- read_csv(
  "data/raw/climate_health_synthetic.csv",
  show_col_types = FALSE
) %>%
  mutate(
    date = as.Date(date),
    region = factor(region),
    month = factor(month)
  )

# Check outcome and exposure variables
summary(climate_health$mean_temp)
summary(climate_health$cardiovascular_cases)
summary(climate_health$respiratory_cases)

# ------------------------------------------------------------
# MODEL 1: Cardiovascular cases
# Poisson regression with population offset
# ------------------------------------------------------------

model_cv <- glm(
  cardiovascular_cases ~ mean_temp + humidity +
    rainfall + region + month +
    offset(log(population)),
  family = poisson(link = "log"),
  data = climate_health
)

summary(model_cv)

# Check Poisson overdispersion
dispersion_cv <- sum(
  residuals(model_cv, type = "pearson")^2
) / df.residual(model_cv)

cat("Cardiovascular model dispersion:",
    dispersion_cv, "\n")

# ------------------------------------------------------------
# MODEL 2: Respiratory cases
# ------------------------------------------------------------

model_resp <- glm(
  respiratory_cases ~ mean_temp + humidity +
    rainfall + region + month +
    offset(log(population)),
  family = poisson(link = "log"),
  data = climate_health
)

summary(model_resp)

dispersion_resp <- sum(
  residuals(model_resp, type = "pearson")^2
) / df.residual(model_resp)

cat("Respiratory model dispersion:",
    dispersion_resp, "\n")

# ------------------------------------------------------------
# Convert temperature coefficients to rate ratios
# ------------------------------------------------------------

extract_temperature_effect <- function(model, outcome_name) {
  
  coef_table <- coef(summary(model))
  
  beta <- coef_table["mean_temp", "Estimate"]
  se <- coef_table["mean_temp", "Std. Error"]
  p_value <- coef_table["mean_temp", "Pr(>|z|)"]
  
  tibble(
    outcome = outcome_name,
    rate_ratio_per_1C = exp(beta),
    ci_lower = exp(beta - 1.96 * se),
    ci_upper = exp(beta + 1.96 * se),
    p_value = p_value
  )
}

temperature_results <- bind_rows(
  extract_temperature_effect(
    model_cv, "Cardiovascular cases"
  ),
  extract_temperature_effect(
    model_resp, "Respiratory cases"
  )
)

print(temperature_results)

# Save model results
dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  temperature_results,
  "outputs/tables/temperature_model_results.csv"
)

cat("\nStatistical models completed.\n")

# ============================================================
# Step 7: Model diagnostics
# ============================================================

# 1. Check Poisson dispersion
dispersion_cv <- sum(
  residuals(model_cv, type = "pearson")^2
) / df.residual(model_cv)

dispersion_resp <- sum(
  residuals(model_resp, type = "pearson")^2
) / df.residual(model_resp)

cat("Cardiovascular dispersion:", dispersion_cv, "\n")
cat("Respiratory dispersion:", dispersion_resp, "\n")

# 2. Display more precise effect estimates
print(temperature_results, digits = 6)

# 3. Check model residuals
par(mfrow = c(2, 2))
plot(model_cv)
par(mfrow = c(1, 1))

# 4. Compare observed and predicted cardiovascular cases
diagnostic_data <- climate_health %>%
  mutate(
    predicted_cv = predict(model_cv, type = "response"),
    predicted_resp = predict(model_resp, type = "response")
  )

p_observed_predicted <- ggplot(
  diagnostic_data,
  aes(x = predicted_cv, y = cardiovascular_cases)
) +
  geom_point(alpha = 0.25) +
  geom_abline(
    slope = 1, intercept = 0, linetype = "dashed"
  ) +
  labs(
    title = "Observed vs Predicted Cardiovascular Cases",
    subtitle = "Synthetic data — model diagnostic",
    x = "Predicted cases",
    y = "Observed cases"
  ) +
  theme_minimal()

print(p_observed_predicted)

# Save diagnostic plot
dir.create(
  "outputs/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

ggsave(
  "outputs/figures/observed_vs_predicted_cv.png",
  p_observed_predicted,
  width = 9,
  height = 6,
  dpi = 300
)
