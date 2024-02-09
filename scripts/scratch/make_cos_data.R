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
prod <- readRDS(here("data", "mex_landings", "clean", "mex_landings_2000_2022.rds"))

## PROCESSING ##################################################################

# Group by year and state ------------------------------------------------------
prod_by_state_and_species <- prod %>% 
  filter(year >= 2003) %>% 
  mutate(source = case_when(acuaculture_production == "SÍ" ~ "acuacultura",
                            acuaculture_production == "NO" ~ "pesca",
                            is.na(acuaculture_production) ~ "pesca")) %>% 
  group_by(year, state, source, main_species_group) %>% 
  summarize(live_weight = sum(live_weight, na.rm = T),
            n_eu = n_distinct(eu_rnpa)) %>% 
  ungroup() %>% 
  mutate(state = str_to_title(state),
         main_species_group = str_to_lower(main_species_group))

## EXPORT ######################################################################
# Export annual by eu ---------------------------------------------------------
saveRDS(object = prod_by_state_and_species,
        file = here("data", "mex_landings", "clean", "mex_annual_wc_aq_by_state.rds"))

write_csv(x = prod_by_state_and_species,
          file = here("data", "mex_landings", "clean", "mex_annual_wc_aq_by_state.csv"))

