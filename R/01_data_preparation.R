# Climate and Health Epidemiology Project

print("R is working correctly")

# Create a small test dataset
library(tidyverse)

test_data <- tibble(
  date = as.Date("2026-01-01") + 0:9,
  mean_temp = c(28, 30, 32, 31, 29, 35, 34, 30, 27, 33),
  cardiovascular_cases = c(12, 14, 15, 13, 11, 18, 17, 13, 10, 16)
)

print(test_data)