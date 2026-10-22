
# ============================================================
# CLIMATE AND HEALTH EPIDEMIOLOGY
# Step 8: Final Report and Professional Figures
# Synthetic data only — not real-world evidence
# ============================================================

library(tidyverse)

# 1. Load data
data_file <- "data/raw/climate_health_synthetic.csv"

if (!file.exists(data_file)) {
  stop("Dataset not found. Check your project folder.")
}

dat <- read_csv(data_file, show_col_types = FALSE) %>%
  mutate(
    date = as.Date(date),
    region = factor(region),
    month = factor(month)
  )

# 2. Create output folders
dir.create("outputs/figures", recursive = TRUE,
           showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE,
           showWarnings = FALSE)
dir.create("reports", recursive = TRUE,
           showWarnings = FALSE)

# 3. Descriptive summary
descriptive <- dat %>%
  summarise(
    records = n(),
    regions = n_distinct(region),
    start_date = min(date),
    end_date = max(date),
    mean_temperature = mean(mean_temp, na.rm = TRUE),
    sd_temperature = sd(mean_temp, na.rm = TRUE),
    mean_humidity = mean(humidity, na.rm = TRUE),
    total_cv_cases = sum(cardiovascular_cases, na.rm = TRUE),
    total_resp_cases = sum(respiratory_cases, na.rm = TRUE)
  )

write_csv(descriptive, "outputs/tables/descriptive_summary.csv")

# 4. Refit Poisson models
model_cv <- glm(
  cardiovascular_cases ~ mean_temp + humidity +
    rainfall + region + month + offset(log(population)),
  family = poisson(link = "log"),
  data = dat
)

model_resp <- glm(
  respiratory_cases ~ mean_temp + humidity +
    rainfall + region + month + offset(log(population)),
  family = poisson(link = "log"),
  data = dat
)

# 5. Extract temperature rate ratios and confidence intervals
extract_effect <- function(model, outcome) {
  sm <- coef(summary(model))
  beta <- sm["mean_temp", "Estimate"]
  se <- sm["mean_temp", "Std. Error"]
  p <- sm["mean_temp", "Pr(>|z|)"]
  
  tibble(
    outcome = outcome,
    rate_ratio = exp(beta),
    ci_lower = exp(beta - 1.96 * se),
    ci_upper = exp(beta + 1.96 * se),
    p_value = p
  )
}

effects <- bind_rows(
  extract_effect(model_cv, "Cardiovascular cases"),
  extract_effect(model_resp, "Respiratory cases")
)

write_csv(effects, "outputs/tables/model_effects.csv")

# 6. Calculate dispersion statistics
dispersion <- tibble(
  outcome = c("Cardiovascular cases", "Respiratory cases"),
  pearson_dispersion = c(
    sum(residuals(model_cv, type = "pearson")^2) /
      df.residual(model_cv),
    sum(residuals(model_resp, type = "pearson")^2) /
      df.residual(model_resp)
  )
)

write_csv(dispersion, "outputs/tables/model_diagnostics.csv")

# 7. Figure 1: Temperature distribution
p1 <- ggplot(dat, aes(x = mean_temp)) +
  geom_histogram(bins = 35, color = "white") +
  labs(
    title = "Distribution of Daily Mean Temperature",
    subtitle = "Synthetic climate-health dataset",
    x = "Mean temperature (°C)",
    y = "Number of region-days"
  ) +
  theme_minimal(base_size = 13)

# 8. Figure 2: Temperature over time
daily <- dat %>%
  group_by(date) %>%
  summarise(temp = mean(mean_temp), .groups = "drop")

p2 <- ggplot(daily, aes(date, temp)) +
  geom_line(alpha = 0.65) +
  geom_smooth(se = FALSE, method = "loess") +
  labs(
    title = "Daily Mean Temperature Over Time",
    x = "Date",
    y = "Mean temperature (°C)"
  ) +
  theme_minimal(base_size = 13)

# 9. Figure 3: Cases by region
regional <- dat %>%
  group_by(region) %>%
  summarise(
    cardiovascular = sum(cardiovascular_cases),
    respiratory = sum(respiratory_cases),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = c(cardiovascular, respiratory),
    names_to = "outcome",
    values_to = "cases"
  )

p3 <- ggplot(regional, aes(region, cases)) +
  geom_col() +
  facet_wrap(~ outcome, scales = "free_y") +
  labs(
    title = "Simulated Health Cases by Region",
    x = "Fictional region",
    y = "Total simulated cases"
  ) +
  theme_minimal(base_size = 13)

# 10. Figure 4: Temperature and cardiovascular cases
p4 <- ggplot(dat, aes(mean_temp, cardiovascular_cases)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Temperature and Cardiovascular Cases",
    subtitle = "Exploratory association; synthetic data",
    x = "Mean temperature (°C)",
    y = "Simulated cases per region-day"
  ) +
  theme_minimal(base_size = 13)

# 11. Figure 5: Temperature and respiratory cases
p5 <- ggplot(dat, aes(mean_temp, respiratory_cases)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Temperature and Respiratory Cases",
    subtitle = "Exploratory association; synthetic data",
    x = "Mean temperature (°C)",
    y = "Simulated cases per region-day"
  ) +
  theme_minimal(base_size = 13)

# 12. Figure 6: Model rate ratios
p6 <- ggplot(effects, aes(x = rate_ratio, y = outcome)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbar(
    aes(xmin = ci_lower, xmax = ci_upper),
    width = 0.2,
    orientation = "y"
  ) +
  geom_point(size = 3) +
  labs(
    title = "Estimated Temperature Association",
    subtitle = "Poisson regression; rate ratio per 1°C increase",
    x = "Rate ratio (95% confidence interval)",
    y = NULL
  ) +
  theme_minimal(base_size = 13)

# 13. Save all figures at publication-quality resolution
ggsave("outputs/figures/01_temperature_distribution.png",
       p1, width = 9, height = 6, dpi = 300)
ggsave("outputs/figures/02_temperature_trend.png",
       p2, width = 10, height = 6, dpi = 300)
ggsave("outputs/figures/03_cases_by_region.png",
       p3, width = 10, height = 6, dpi = 300)
ggsave("outputs/figures/04_temperature_cardiovascular.png",
       p4, width = 9, height = 6, dpi = 300)
ggsave("outputs/figures/05_temperature_respiratory.png",
       p5, width = 9, height = 6, dpi = 300)
ggsave("outputs/figures/06_model_rate_ratios.png",
       p6, width = 10, height = 5, dpi = 300)

# 14. Build a report using actual model outputs
fmt <- function(x, digits = 3) {
  formatC(x, format = "f", digits = digits)
}

effect_lines <- apply(effects, 1, function(x) {
  paste0(
    "| ", x[["outcome"]], " | ",
    fmt(as.numeric(x[["rate_ratio"]])), " | ",
    fmt(as.numeric(x[["ci_lower"]])), "–",
    fmt(as.numeric(x[["ci_upper"]])), " | ",
    format.pval(as.numeric(x[["p_value"]]), digits = 3),
    " |"
  )
})

disp_lines <- apply(dispersion, 1, function(x) {
  paste0(
    "- ", x[["outcome"]], ": Pearson dispersion = ",
    fmt(as.numeric(x[["pearson_dispersion"]]))
  )
})

report <- c(
  "# Climate and Health Epidemiology",
  "",
  "## Project status and data disclaimer",
  "",
  "**This is a methodological training project using entirely synthetic data.**",
  "The dataset does not represent real patients, actual regions, or observed",
  "population health events. Results must not be interpreted as real-world",
  "scientific evidence or used to guide clinical or public-health decisions.",
  "",
  "## Research question",
  "",
  "How are daily mean temperature and simulated cardiovascular and respiratory",
  "case counts associated in this fictional dataset?",
  "",
  "## Dataset",
  "",
  paste0("- Region-day records: ", nrow(dat)),
  paste0("- Fictional regions: ", n_distinct(dat$region)),
  paste0("- Study period: ", min(dat$date), " to ", max(dat$date)),
  paste0("- Mean temperature: ", fmt(mean(dat$mean_temp)), " °C"),
  "",
  "## Methods",
  "",
  "Exploratory analysis used descriptive statistics and plots.",
  "Separate Poisson regression models were fitted for cardiovascular and",
  "respiratory counts. Models included mean temperature, humidity, rainfall,",
  "region, month, and a log-population offset.",
  "",
  "Rate ratios are reported per 1°C increase in mean temperature, with",
  "Wald 95% confidence intervals. Pearson dispersion statistics were",
  "calculated as a preliminary diagnostic.",
  "",
  "## Results",
  "",
  paste0("- Total simulated cardiovascular cases: ",
         sum(dat$cardiovascular_cases)),
  paste0("- Total simulated respiratory cases: ",
         sum(dat$respiratory_cases)),
  "",
  "| Outcome | Rate ratio | 95% CI lower–upper | p-value |",
  "|---|---:|---:|---:|",
  effect_lines,
  "",
  "### Preliminary model diagnostics",
  "",
  disp_lines,
  "",
  "Dispersion values near 1 are broadly consistent with the Poisson variance",
  "assumption, but do not alone establish model adequacy. Residual patterns,",
  "sensitivity analyses, temporal structure, and alternative count models",
  "should be examined before drawing methodological conclusions.",
  "",
  "## Interpretation",
  "",
  "The estimated associations describe the behavior of a simulated dataset",
  "whose outcomes were generated using predefined rules. They do not establish",
  "that temperature causes changes in cardiovascular or respiratory health.",
  "Small p-values in synthetic data are not evidence of a real health effect.",
  "",
  "## Limitations",
  "",
  "- All data are synthetic and do not represent real populations.",
  "- The outcome-generating process includes predefined temperature effects.",
  "- The models do not address all potential temporal dependencies or delayed",
  "  effects of temperature.",
  "- Model diagnostics and sensitivity analyses are preliminary.",
  "- Real-world inference requires validated data and a prespecified study design.",
  "",
  "## Reproducibility",
  "",
  "Run `06_final_report.R` from the project root in RStudio.",
  "Tables are saved in `outputs/tables/` and figures in `outputs/figures/`.",
  "",
  "## Next steps",
  "",
  "1. Validate the modeling strategy and diagnostics.",
  "2. Conduct sensitivity analyses and consider nonlinear or lagged effects.",
  "3. If feasible, replace synthetic data with ethically and legally usable",
  "   real data from documented, trustworthy sources.",
  "4. Update this report before presenting any real-world conclusions."
)

writeLines(report, "reports/final_report.md")

# 15. Print plots and completion message
print(p1)
print(p2)
print(p3)
print(p4)
print(p5)
print(p6)

cat("\nFINAL REPORT CREATED SUCCESSFULLY\n")
cat("Report: reports/final_report.md\n")
cat("Figures: outputs/figures/\n")
cat("Tables: outputs/tables/\n")
