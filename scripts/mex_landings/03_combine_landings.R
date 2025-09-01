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

# Load and define functions ----------------------------------------------------
source(here("scripts", "00_setup.R"))

# Load data --------------------------------------------------------------------
stuart <- readRDS(here("data", "mex_landings", "clean", "mex_conapesca_avisos_2000_2019.rds")) |> 
  filter(year_cut <= 2017)

apertura <- readRDS(here("data", "mex_landings", "clean", "mex_conapesca_apertura_2018_present.rds"))

months <- tibble(month_cut = c("ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"),
                 month = 1:12) 

## PROCESSING ##################################################################

# Combine and select columns ---------------------------------------------------
landings <- bind_rows(stuart,
                      apertura) |> 
  left_join(months, by = "month_cut")

# Fix dates --------------------------------------------------------------------
landings_fixed_dates <- landings %>%
  mutate(period_start_fixed = fix_dates(data = .,
                                        date_to_fix = period_start),
         period_end_fixed = fix_dates(data = .,
                                      date_to_fix = period_end),
         receipt_date_fixed = fix_dates(data = .,
                                        date_to_fix = receipt_date))


final_landings <- landings_fixed_dates |> 
  select(state,
         office_name,
         landing_site,
         landing_site_key,
         year = year_cut,
         month = month,
         receipt_date_fixed,
         period_end_fixed,
         period_start_fixed,
         eu_rnpa,
         eu_name = economic_unit,
         fleet,
         acuaculture_production,
         vessel_rnpa,
         vessel_name,
         main_species_group,
         landed_weight,
         live_weight,
         value)

## EXPORT ######################################################################

# Export file ------------------------------------------------------------------
saveRDS(object = final_landings,
        file = here("data", "mex_landings", "clean", "mex_landings_2000_present.rds"))
