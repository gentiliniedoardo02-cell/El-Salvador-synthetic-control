# ==================================================
# El Salvador Synthetic Control
# Script 01: Data Cleaning
# ==================================================

library(tidyverse)
library(readxl)

setwd("~/Desktop/el salvador")

paesi <- c("El Salvador", "Costa Rica", "Dominican Republic", "Guatemala",
           "Nicaragua", "Panama", "Ecuador", "Honduras",
           "Paraguay", "Belize", "Bolivia", "Peru")

# --------------------------------------------------
# 1. WDI DATA — 2010-2023 (file originale)
# --------------------------------------------------

wdi_raw <- read_csv("Data.csv")

wdi <- wdi_raw %>%
  filter(`Country Name` %in% paesi) %>%
  filter(!is.na(Time)) %>%
  rename(
    country     = `Country Name`,
    iso3        = `Country Code`,
    year        = Time,
    gdp_growth  = `GDP growth (annual %) [NY.GDP.MKTP.KD.ZG]`,
    gdp_pc      = `GDP per capita growth (annual %) [NY.GDP.PCAP.KD.ZG]`,
    fdi         = `Foreign direct investment, net inflows (% of GDP) [BX.KLT.DINV.WD.GD.ZS]`,
    trade       = `Trade (% of GDP) [NE.TRD.GNFS.ZS]`,
    inflation   = `Inflation, consumer prices (annual %) [FP.CPI.TOTL.ZG]`,
    remittances = `Personal remittances, received (% of GDP) [BX.TRF.PWKR.DT.GD.ZS]`,
    tourism     = `International tourism, number of arrivals [ST.INT.ARVL]`
  ) %>%
  filter(year >= 2010, year <= 2023) %>%
  select(country, iso3, year, gdp_growth, gdp_pc, fdi,
         trade, inflation, remittances, tourism) %>%
  mutate(tourism = as.numeric(tourism))

# --------------------------------------------------
# 2. UNODC HOMICIDE DATA
# --------------------------------------------------

unodc_raw <- read_excel("data_cts_intentional_homicide.xlsx",
                        sheet = "data_cts_intentional_homicide",
                        skip = 1)

colnames(unodc_raw) <- as.character(unodc_raw[1, ])
unodc_raw <- unodc_raw[-1, ]
unodc_raw$Year  <- as.numeric(unodc_raw$Year)
unodc_raw$VALUE <- as.numeric(unodc_raw$VALUE)

homicide <- unodc_raw %>%
  filter(Country %in% paesi,
         Dimension == "Total",
         Sex == "Total",
         Age == "Total",
         `Unit of measurement` == "Rate per 100,000 population") %>%
  group_by(Country, Year) %>%
  summarise(homicide_rate = max(VALUE, na.rm = TRUE), .groups = "drop") %>%
  rename(country = Country, year = Year) %>%
  filter(year >= 2010, year <= 2023)

# --------------------------------------------------
# 3. GDP PER CAPITA — LIVELLO (variabile aggiuntiva)
# --------------------------------------------------

gdppc_raw <- read_csv("gdppc_level.csv")

gdppc <- gdppc_raw %>%
  filter(`Country Name` %in% paesi) %>%
  filter(!is.na(Time)) %>%
  rename(
    country     = `Country Name`,
    year        = Time,
    gdppc_level = `GDP per capita (constant 2015 US$) [NY.GDP.PCAP.KD]`
  ) %>%
  mutate(gdppc_level = as.numeric(gdppc_level)) %>%
  filter(year >= 2010, year <= 2023) %>%
  select(country, year, gdppc_level)

# --------------------------------------------------
# 4. MERGE — PANEL 2010-2023
# --------------------------------------------------

panel <- wdi %>%
  left_join(homicide, by = c("country", "year")) %>%
  left_join(gdppc, by = c("country", "year"))

glimpse(panel)

write_csv(panel, "panel_clean.csv")
cat("Panel 2010-2023 salvato:", nrow(panel), "righe,", n_distinct(panel$country), "paesi\n")

# --------------------------------------------------
# 5. PANEL ESTESO AL 2024
# --------------------------------------------------

data24_raw <- read_csv("Data_2024.csv")

panel_24 <- data24_raw %>%
  filter(`Country Name` %in% paesi) %>%
  filter(!is.na(Time)) %>%
  rename(
    country     = `Country Name`,
    iso3        = `Country Code`,
    year        = Time,
    gdp_growth  = `GDP growth (annual %) [NY.GDP.MKTP.KD.ZG]`,
    gdppc_level = `GDP per capita (constant 2015 US$) [NY.GDP.PCAP.KD]`,
    fdi         = `Foreign direct investment, net inflows (% of GDP) [BX.KLT.DINV.WD.GD.ZS]`,
    trade       = `Trade (% of GDP) [NE.TRD.GNFS.ZS]`,
    inflation   = `Inflation, consumer prices (annual %) [FP.CPI.TOTL.ZG]`,
    remittances = `Personal remittances, received (% of GDP) [BX.TRF.PWKR.DT.GD.ZS]`,
    tourism     = `International tourism, number of arrivals [ST.INT.ARVL]`
  ) %>%
  mutate(across(c(gdp_growth, gdppc_level, fdi, trade, inflation, remittances, tourism), as.numeric)) %>%
  filter(year >= 2010, year <= 2024) %>%
  select(country, iso3, year, gdp_growth, gdppc_level, fdi, trade, inflation, remittances, tourism)

homicide_data <- panel %>% select(country, year, homicide_rate)

panel_final <- panel_24 %>%
  left_join(homicide_data, by = c("country", "year"))

glimpse(panel_final)

write_csv(panel_final, "panel_clean_2024.csv")
cat("Panel 2010-2024 salvato:", nrow(panel_final), "righe\n")