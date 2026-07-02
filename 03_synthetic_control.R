# ==================================================
# El Salvador Synthetic Control
# Script 03: Synthetic Control Analysis
# ==================================================
#
# NOTA: tidysynth 0.2.1 richiede dplyr <= 1.1.4
# Se "Can't supply both `.by` and `.groups`":
#   remotes::install_version("dplyr", version = "1.1.4") + Restart R
# NOTA 2: plot_differences() e plot_placebos() hanno un bug interno
# con questa combinazione di versioni — OMESSI. plot_trends(),
# grab_significance() e grab_unit_weights() bastano per tutti i risultati.

library(tidyverse)
library(tidysynth)

setwd("~/Desktop/el salvador")

paesi <- c("El Salvador", "Costa Rica", "Dominican Republic", "Guatemala",
           "Nicaragua", "Panama", "Ecuador", "Honduras",
           "Paraguay", "Belize", "Bolivia", "Peru")

panel <- read_csv("panel_clean.csv")

# ==================================================
# PARTE A — BASELINE (2010-2023, 12 paesi)
# ==================================================

sc_gdp <- panel %>%
  synthetic_control(
    outcome = gdp_growth, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    gdp_growth_mean = mean(gdp_growth, na.rm = TRUE),
    trade           = mean(trade, na.rm = TRUE),
    inflation       = mean(inflation, na.rm = TRUE),
    remittances     = mean(remittances, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_gdp %>% plot_trends() +
  labs(title = "GDP Growth: El Salvador vs Synthetic El Salvador",
       caption = "Treatment: estado de excepción (2022)") + theme_minimal()
ggsave("sc_gdp_trends.png", width = 8, height = 5, dpi = 300)

sc_gdp %>% grab_unit_weights() %>% arrange(desc(weight)) %>% print()
sc_gdp_sig <- sc_gdp %>% grab_significance()
print(sc_gdp_sig)

sc_fdi <- panel %>%
  synthetic_control(
    outcome = fdi, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    fdi_mean        = mean(fdi, na.rm = TRUE),
    gdp_growth_mean = mean(gdp_growth, na.rm = TRUE),
    trade           = mean(trade, na.rm = TRUE),
    inflation       = mean(inflation, na.rm = TRUE),
    remittances     = mean(remittances, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_fdi %>% plot_trends() +
  labs(title = "FDI: El Salvador vs Synthetic El Salvador",
       caption = "Treatment: estado de excepción (2022)") + theme_minimal()
ggsave("sc_fdi_trends.png", width = 8, height = 5, dpi = 300)

sc_fdi %>% grab_unit_weights() %>% arrange(desc(weight)) %>% print()
sc_fdi_sig <- sc_fdi %>% grab_significance()
print(sc_fdi_sig)

cat("Parte A (baseline) completata.\n")

# ==================================================
# PARTE B — ROBUSTEZZA: DONOR POOL SENZA BELIZE
# ==================================================

panel_rob <- panel %>% filter(country != "Belize")

sc_gdp_rob <- panel_rob %>%
  synthetic_control(
    outcome = gdp_growth, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    gdp_growth_mean = mean(gdp_growth, na.rm = TRUE),
    trade           = mean(trade, na.rm = TRUE),
    inflation       = mean(inflation, na.rm = TRUE),
    remittances     = mean(remittances, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_gdp_rob %>% plot_trends() +
  labs(title = "GDP Growth (no Belize): El Salvador vs Synthetic",
       caption = "Robustness check — donor pool senza Belize") + theme_minimal()
ggsave("sc_gdp_rob_trends.png", width = 8, height = 5, dpi = 300)

sc_gdp_rob %>% grab_significance() %>% print()
sc_gdp_rob %>% grab_unit_weights() %>% arrange(desc(weight)) %>% print()

sc_fdi_rob <- panel_rob %>%
  synthetic_control(
    outcome = fdi, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    fdi_mean        = mean(fdi, na.rm = TRUE),
    gdp_growth_mean = mean(gdp_growth, na.rm = TRUE),
    trade           = mean(trade, na.rm = TRUE),
    inflation       = mean(inflation, na.rm = TRUE),
    remittances     = mean(remittances, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_fdi_rob %>% plot_trends() +
  labs(title = "FDI (no Belize): El Salvador vs Synthetic",
       caption = "Robustness check — donor pool senza Belize") + theme_minimal()
ggsave("sc_fdi_rob_trends.png", width = 8, height = 5, dpi = 300)

sc_fdi_rob %>% grab_significance() %>% print()
sc_fdi_rob %>% grab_unit_weights() %>% arrange(desc(weight)) %>% print()

cat("Parte B (robustezza no Belize) completata.\n")

# ==================================================
# PARTE C — PREDICTOR ESTESI (GDPpc level) + DATI FINO AL 2024
# ==================================================

panel_final <- read_csv("panel_clean_2024.csv")

sc_gdp_v2 <- panel %>%
  synthetic_control(
    outcome = gdp_growth, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    gdp_growth_mean  = mean(gdp_growth, na.rm = TRUE),
    gdppc_level_mean = mean(gdppc_level, na.rm = TRUE),
    trade            = mean(trade, na.rm = TRUE),
    inflation        = mean(inflation, na.rm = TRUE),
    remittances      = mean(remittances, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_gdp_v2 %>% plot_trends() +
  labs(title = "GDP Growth (with GDPpc level): El Salvador vs Synthetic") + theme_minimal()
ggsave("sc_gdp_v2_trends.png", width = 8, height = 5, dpi = 300)
sc_gdp_v2 %>% grab_significance() %>% print()

sc_fdi_v2 <- panel %>%
  synthetic_control(
    outcome = fdi, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    fdi_mean         = mean(fdi, na.rm = TRUE),
    gdppc_level_mean = mean(gdppc_level, na.rm = TRUE),
    gdp_growth_mean  = mean(gdp_growth, na.rm = TRUE),
    trade            = mean(trade, na.rm = TRUE),
    inflation        = mean(inflation, na.rm = TRUE),
    remittances      = mean(remittances, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_fdi_v2 %>% plot_trends() +
  labs(title = "FDI (with GDPpc level): El Salvador vs Synthetic") + theme_minimal()
ggsave("sc_fdi_v2_trends.png", width = 8, height = 5, dpi = 300)
sc_fdi_v2 %>% grab_significance() %>% print()

panel_final_nb <- panel_final %>% filter(country != "Bolivia")

sc_gdp_24 <- panel_final_nb %>%
  synthetic_control(
    outcome = gdp_growth, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    gdp_growth_mean  = mean(gdp_growth, na.rm = TRUE),
    gdppc_level_mean = mean(gdppc_level, na.rm = TRUE),
    trade            = mean(trade, na.rm = TRUE),
    inflation        = mean(inflation, na.rm = TRUE),
    remittances      = mean(remittances, na.rm = TRUE),
    homicide_rate    = mean(homicide_rate, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_gdp_24 %>% plot_trends() +
  labs(title = "GDP Growth 2010-2024: El Salvador vs Synthetic",
       caption = "Post-treatment: 2022-2024 (no Bolivia)") + theme_minimal()
ggsave("sc_gdp_2024_trends.png", width = 8, height = 5, dpi = 300)
sc_gdp_24 %>% grab_significance() %>% print()

sc_fdi_24 <- panel_final_nb %>%
  synthetic_control(
    outcome = fdi, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    fdi_mean         = mean(fdi, na.rm = TRUE),
    gdppc_level_mean = mean(gdppc_level, na.rm = TRUE),
    gdp_growth_mean  = mean(gdp_growth, na.rm = TRUE),
    trade            = mean(trade, na.rm = TRUE),
    inflation        = mean(inflation, na.rm = TRUE),
    remittances      = mean(remittances, na.rm = TRUE),
    homicide_rate    = mean(homicide_rate, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_fdi_24 %>% plot_trends() +
  labs(title = "FDI 2010-2024: El Salvador vs Synthetic",
       caption = "Post-treatment: 2022-2024 (no Bolivia)") + theme_minimal()
ggsave("sc_fdi_2024_trends.png", width = 8, height = 5, dpi = 300)
sc_fdi_24 %>% grab_significance() %>% print()

panel_final_nb2 <- panel_final_nb %>% filter(country != "Belize")

sc_fdi_24_rob <- panel_final_nb2 %>%
  synthetic_control(
    outcome = fdi, unit = country, time = year,
    i_unit = "El Salvador", i_time = 2022, generate_placebos = TRUE
  ) %>%
  generate_predictor(
    time_window = 2010:2021,
    fdi_mean         = mean(fdi, na.rm = TRUE),
    gdppc_level_mean = mean(gdppc_level, na.rm = TRUE),
    gdp_growth_mean  = mean(gdp_growth, na.rm = TRUE),
    trade            = mean(trade, na.rm = TRUE),
    inflation        = mean(inflation, na.rm = TRUE),
    remittances      = mean(remittances, na.rm = TRUE),
    homicide_rate    = mean(homicide_rate, na.rm = TRUE)
  ) %>%
  generate_weights(optimization_window = 2010:2021, margin_ipop = .02, sigf_ipop = 7, bound_ipop = 6) %>%
  generate_control()

sc_fdi_24_rob %>% plot_trends() +
  labs(title = "FDI 2010-2024 (no Belize): El Salvador vs Synthetic",
       caption = "Post-treatment: 2022-2024 — donor pool senza Belize e Bolivia") + theme_minimal()
ggsave("sc_fdi_2024_rob_trends.png", width = 8, height = 5, dpi = 300)
sc_fdi_24_rob %>% grab_significance() %>% print()
sc_fdi_24_rob %>% grab_unit_weights() %>% arrange(desc(weight)) %>% print()

cat("Script 03 completato integralmente.\n")