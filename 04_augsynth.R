# Script 04: Augmented Synthetic Control (robustezza finale)
library(tidyverse)
library(augsynth)

setwd("~/Desktop/el salvador")

panel_aug_base <- read_csv("panel_clean_2024.csv") %>%
  filter(country != "Bolivia", country != "Belize")

panel_aug <- panel_aug_base %>%
  mutate(treatment = if_else(country == "El Salvador" & year >= 2022, 1, 0))

# FDI augmented synthetic control

aug_fdi <- augsynth(
  fdi ~ treatment,
  unit = country,
  time = year,
  data = panel_aug,
  progfunc = "Ridge",
  scm = TRUE
)

summary(aug_fdi)

s_fdi <- summary(aug_fdi)
plot(s_fdi)
ggsave("aug_fdi_trends.png", width = 8, height = 5, dpi = 300)

# GDP GROWTH augmented synthetic control
aug_gdp <- augsynth(
  gdp_growth ~ treatment,
  unit = country,
  time = year,
  data = panel_aug,
  progfunc = "Ridge",
  scm = TRUE
)

summary(aug_gdp)

s_gdp <- summary(aug_gdp)
plot(s_gdp)
ggsave("aug_gdp_trends.png", width = 8, height = 5, dpi = 300)

cat("Script 04 (augsynth) completato.\n")
