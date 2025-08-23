################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Description
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  here,
  tidyverse
)

# Load data --------------------------------------------------------------------
landings <- readRDS(here("data", "mex_landings", "clean", "mex_landings_2000_present.rds")) %>% 
  filter(!acuaculture_production == "SÍ" | is.na(acuaculture_production))

## PROCESSING ##################################################################

# Process monthly by vessel ----------------------------------------------------
monthly_by_vessel <- landings %>% 
  group_by(year, month, eu_rnpa, vessel_rnpa, main_species_group) %>% 
  summarize(landed_weight = sum(landed_weight, na.rm = T),
            live_weight = sum(live_weight, na.rm = T),
            value = sum(value, na.rm = T)) %>% 
  ungroup()

# Process annual by vessel -----------------------------------------------------
annual_by_vessel <- monthly_by_vessel %>% 
  group_by(year, eu_rnpa, vessel_rnpa, main_species_group) %>% 
  summarize(landed_weight = sum(landed_weight, na.rm = T),
            live_weight = sum(live_weight, na.rm = T),
            value = sum(value, na.rm = T)) %>% 
  ungroup()

# Process monthly by eu --------------------------------------------------------
monthly_by_eu <- monthly_by_vessel %>% 
  group_by(year, month, eu_rnpa, main_species_group) %>% 
  summarize(landed_weight = sum(landed_weight, na.rm = T),
            live_weight = sum(live_weight, na.rm = T),
            value = sum(value, na.rm = T)) %>% 
  ungroup()

# Process annual by eu ---------------------------------------------------------
annual_by_eu <- monthly_by_eu %>% 
  group_by(year, eu_rnpa, main_species_group) %>% 
  summarize(landed_weight = sum(landed_weight, na.rm = T),
            live_weight = sum(live_weight, na.rm = T),
            value = sum(value, na.rm = T)) %>% 
  ungroup()


## EXPORT ######################################################################

# Export monthly by vessel ----------------------------------------------------
saveRDS(object = monthly_by_vessel,
        file = here("data", "mex_landings", "clean", "mex_monthly_landings_by_vessel.rds"))

# Export annual by vessel -----------------------------------------------------
saveRDS(object = annual_by_vessel,
        file = here("data", "mex_landings", "clean", "mex_annual_landings_by_vessel.rds"))

# Export monthly by eu --------------------------------------------------------
saveRDS(object = monthly_by_eu,
        file = here("data", "mex_landings", "clean", "mex_monthly_landings_by_eu.rds"))

# Export annual by eu ---------------------------------------------------------
saveRDS(object = annual_by_eu,
        file = here("data", "mex_landings", "clean", "mex_annual_landings_by_eu.rds"))

