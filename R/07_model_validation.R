
# 07_model_validation.R
# Model validation for synthetic climate-health data

library(tidyverse)
library(MASS)

# Load data
df <- read.csv(
  "data/raw/climate_health_synthetic.csv"
)

df$date <- as.Date(df$date)
df$region <- as.factor(df$region)
df$month <- as.factor(df$month)

# Poisson models
model_cv_pois <- glm(
  cardiovascular_cases ~ mean_temp + humidity +
    rainfall + region + month +
    offset(log(population)),
  family = poisson(link = "log"),
  data = df
)

model_resp_pois <- glm(
  respiratory_cases ~ mean_temp + humidity +
    rainfall + region + month +
    offset(log(population)),
  family = poisson(link = "log"),
  data = df
)

# Negative Binomial comparison
model_cv_nb <- MASS::glm.nb(
  cardiovascular_cases ~ mean_temp + humidity +
    rainfall + region + month +
    offset(log(population)),
  data = df
)

model_resp_nb <- MASS::glm.nb(
  respiratory_cases ~ mean_temp + humidity +
    rainfall + region + month +
    offset(log(population)),
  data = df
)

# Compare AIC: lower is preferred among comparable models
comparison <- data.frame(
  Outcome = c(
    "Cardiovascular",
    "Cardiovascular",
    "Respiratory",
    "Respiratory"
  ),
  Model = c(
    "Poisson",
    "Negative Binomial",
    "Poisson",
    "Negative Binomial"
  ),
  AIC = c(
    AIC(model_cv_pois),
    AIC(model_cv_nb),
    AIC(model_resp_pois),
    AIC(model_resp_nb)
  )
)

print(comparison)

# Save comparison
dir.create("outputs/tables", showWarnings = FALSE,
           recursive = TRUE)

write.csv(
  comparison,
  "outputs/tables/model_comparison.csv",
  row.names = FALSE
)

# Residual diagnostic plots
dir.create("outputs/figures", showWarnings = FALSE,
           recursive = TRUE)

png(
  "outputs/figures/07_cv_residuals.png",
  width = 1200, height = 800
)
par(mfrow = c(2, 2))
plot(model_cv_pois)
dev.off()

png(
  "outputs/figures/08_respiratory_residuals.png",
  width = 1200, height = 800
)
par(mfrow = c(2, 2))
plot(model_resp_pois)
dev.off()

cat("Model validation completed.\n")
