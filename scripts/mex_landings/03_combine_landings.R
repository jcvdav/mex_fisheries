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
library(here)
library(tidyverse)

# Load data --------------------------------------------------------------------
stuart <- readRDS(here("data", "mex_landings", "clean", "mex_conapesca_avisos_2000_2019.rds")) %>% 
  filter(year_cut <= 2017)
       
apertura <- readRDS(here("data", "mex_landings", "clean", "mex_conapesca_apertura_2018_2022.rds"))

months <- tibble(month_cut = c("ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"),
                 month = 1:12) 

## PROCESSING ##################################################################

# Combine and select columns ---------------------------------------------------
landings <- bind_rows(stuart, apertura, .id = "source") %>% 
  left_join(months, by = "month_cut") %>% 
  select(source,
         state,
         office_name,
         year = year_cut,
         month = month,
         eu_rnpa,
         economic_unit,
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
saveRDS(object = landings,
        file = here("data", "mex_landings", "clean", "mex_landings_2000_2022.rds"))
