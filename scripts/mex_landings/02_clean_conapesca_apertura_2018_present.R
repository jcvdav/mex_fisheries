################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Cleaing data from: https://conapesca.gob.mx/wb/cona/avisos_arribo_cosecha_produccion
#
# Data last downloaded on June 9, 2023
# 
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  here,
  readxl,
  tidyverse,
  stringi
)

# Load and define functions ----------------------------------------------------
source(here("scripts", "00_setup.R"))

col.names = c("vessel_rnpa", "vessel_name",
              "landing_site_key", "landing_site",
              "eu_rnpa", "economic_unit",
              "state", "office_key",
              "office_name", "receipt_type",
              "receipt_id", "receipt_date",
              "origin", "fishing_site_key",
              "fishing_site_name", "n_vessels",
              "month_cut", "year_cut",
              "period_start", "period_end",
              "period_length", "period_effective_days",
              "fishing_zone_type", "acuaculture_production",
              "permit_number", "permit_issue_date",
              "permit_expiration_date", "main_species_group",
              "species_key", "species_name",
              "landed_weight", "live_weight",
              "price", "value",
              "coastline")

# Load data --------------------------------------------------------------------
files <- list.files(path = here("data", "mex_landings", "raw", "CONAPESCA"),
                    pattern = "*\\.csv",
                    full.names = T)
# Read files--------------------------------------------------------------------
landings <- map_dfr(
  files, 
    ~readr::read_csv(
      .x,
      col_types = cols(.default = "c"), 
      col_names = col.names, 
      skip = 3, 
      locale = locale(encoding = "UTF-8")
    )
) %>% 
  janitor::clean_names() 

## PROCESSING ##################################################################

# Rename and filter ------------------------------------------------------------
landings_clean <- landings %>% 
  mutate(
    vessel_rnpa = stri_enc_toutf8(vessel_rnpa),
    eu_rnpa = stri_enc_toutf8(eu_rnpa),
    vessel_rnpa = stri_replace_all_regex(vessel_rnpa, "[^\\p{L}\\p{N}]", ""),
    eu_rnpa = stri_replace_all_regex(eu_rnpa, "[^\\p{L}\\p{N}]", ""),
    
    landed_weight = as.numeric(str_replace_all(landed_weight, "[^0-9.]", "")),
    live_weight = as.numeric(str_replace_all(live_weight, "[^0-9.]", "")),
    value = as.numeric(str_replace_all(value, "[^0-9.]", "")),
    year_cut = as.numeric(str_replace_all(year_cut, "[^0-9]", ""))
  ) %>% 
  select(
    state,
    office_name,
    vessel_rnpa,
    vessel_name,
    landing_site,
    eu_rnpa,
    economic_unit,
    origin,
    fishing_site_name,
    n_vessels,
    month_cut,
    year_cut,
    period_start,
    period_end,
    period_length,
    period_effective_days,
    fishing_zone_type,
    acuaculture_production,
    permit_number,
    permit_issue_date,
    permit_expiration_date,
    main_species_group,
    species_key,
    species_name,
    landed_weight,
    live_weight,
    price,
    value ) %>% 
  mutate(
    year_cut = as.numeric(year_cut),
    acuaculture_production = case_when(acuaculture_production == "SÃ\u008d" ~ "SÍ",
                                       acuaculture_production == "NO" ~ "NO",
                                       T ~ NA_character_),
    eu_rnpa = fix_rnpa(eu_rnpa, length = 10),
    vessel_rnpa = fix_rnpa(vessel_rnpa))

## EXPORT ######################################################################

# Export file  000--------------------------------------------------------------
saveRDS(object = landings_clean,
        file = here("data", "mex_landings", "clean", "mex_conapesca_apertura_2018_present.rds"))
