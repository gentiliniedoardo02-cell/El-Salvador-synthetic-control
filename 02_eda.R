# ==================================================
# El Salvador Synthetic Control
# Script 02: Exploratory Data Analysis
# ==================================================

library(tidyverse)

setwd("~/Desktop/el salvador")
panel <- read_csv("panel_clean.csv")

panel <- panel %>%
  mutate(group = ifelse(country == "El Salvador", "El Salvador", "Altri paesi"))

cols <- c("El Salvador" = "#E63946", "Altri paesi" = "#AAAAAA")

# --------------------------------------------------
# 1. GDP GROWTH
# --------------------------------------------------

ggplot(panel, aes(x = year, y = gdp_growth, group = country, color = group)) +
  geom_line(aes(alpha = group), linewidth = 0.8) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "black") +
  scale_color_manual(values = cols) +
  scale_alpha_manual(values = c("El Salvador" = 1, "Altri paesi" = 0.4), guide = "none") +
  labs(title = "GDP Growth — El Salvador vs Donor Pool",
       x = NULL, y = "GDP growth (annual %)", color = NULL,
       caption = "Linea tratteggiata: estado de excepción (2022)") +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("plot_gdp.png", width = 8, height = 5, dpi = 300)

# --------------------------------------------------
# 2. FDI
# --------------------------------------------------

ggplot(panel, aes(x = year, y = fdi, group = country, color = group)) +
  geom_line(aes(alpha = group), linewidth = 0.8) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "black") +
  scale_color_manual(values = cols) +
  scale_alpha_manual(values = c("El Salvador" = 1, "Altri paesi" = 0.4), guide = "none") +
  labs(title = "FDI Net Inflows — El Salvador vs Donor Pool",
       x = NULL, y = "FDI (% of GDP)", color = NULL,
       caption = "Linea tratteggiata: estado de excepción (2022)") +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("plot_fdi.png", width = 8, height = 5, dpi = 300)

# --------------------------------------------------
# 3. HOMICIDE RATE
# --------------------------------------------------

ggplot(panel, aes(x = year, y = homicide_rate, group = country, color = group)) +
  geom_line(aes(alpha = group), linewidth = 0.8) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "black") +
  scale_color_manual(values = cols) +
  scale_alpha_manual(values = c("El Salvador" = 1, "Altri paesi" = 0.4), guide = "none") +
  labs(title = "Homicide Rate — El Salvador vs Donor Pool",
       x = NULL, y = "Omicidi per 100,000 abitanti", color = NULL,
       caption = "Linea tratteggiata: estado de excepción (2022)") +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("plot_homicide.png", width = 8, height = 5, dpi = 300)

# --------------------------------------------------
# 4. REMITTANCES
# --------------------------------------------------

ggplot(panel, aes(x = year, y = remittances, group = country, color = group)) +
  geom_line(aes(alpha = group), linewidth = 0.8) +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "black") +
  scale_color_manual(values = cols) +
  scale_alpha_manual(values = c("El Salvador" = 1, "Altri paesi" = 0.4), guide = "none") +
  labs(title = "Remittances — El Salvador vs Donor Pool",
       x = NULL, y = "Rimesse (% of GDP)", color = NULL,
       caption = "Linea tratteggiata: estado de excepción (2022)") +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("plot_remittances.png", width = 8, height = 5, dpi = 300)

cat("Grafici EDA salvati.\n")