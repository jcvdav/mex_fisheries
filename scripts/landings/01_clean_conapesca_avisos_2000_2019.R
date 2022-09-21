# Load packages
library(here)
library(janitor)
library(data.table)
library(tidyverse)

source(here("scripts", "00_setup.R"))

# Function to read and clean
my_read <- function(path){
  fread(path,
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
                      "period_length", "period_effective_dates",
                      "fishing_zone_type", "acuaculture_production",
                      "permit_number", "permit_issue_date",
                      "permit_expiration_date", "main_species_group",
                      "species_key", "species_name",
                      "landed_weight", "live_weight",
                      "price", "value",
                      "coastline"),
        select = 1:35,
        colClasses = "character",
        na.strings = c("NULL", "NA"),
        blank.lines.skip = TRUE) %>% 
    janitor::clean_names() %>% 
    mutate(source = basename(path),
           landed_weight = as.numeric(landed_weight),
           value = as.numeric(value))
}

files <- list.files(path = here("data", "mex_landings", "raw", "CONAPESCA Avisos 2000-2019"),
                    pattern = "*.csv",
                    full.names = T)

dt <- map_dfr(files, my_read)

setkey(dt, eu_rnpa, vessel_rnpa, year_cut)

annual_vessel_landings <- dt %>% 
  .[!acuaculture_production == "SÍ"| 
      !fishing_zone_type == "AGUAS CONTINENTALES" |
      !is.na(eu_rnpa) |
      !is.na(vessel_rnpa)] %>% 
  .[,`:=`(eu_rnpa = fix_rnpa(rnpa = eu_rnpa, length = 10),
          vessel_rnpa = fix_rnpa(rnpa = vessel_rnpa))] %>%
  .[, .(landed_weight = sum(landed_weight, na.rm = T),
        value = sum(value, na.rm = T)),
    by = .(year_cut, eu_rnpa, vessel_rnpa, main_species_group)] 

monthly_vessel_landings <- dt %>% 
  .[!acuaculture_production == "SÍ"| 
      !fishing_zone_type == "AGUAS CONTINENTALES" |
      !is.na(eu_rnpa) |
      !is.na(vessel_rnpa)] %>% 
  .[,`:=`(eu_rnpa = fix_rnpa(rnpa = eu_rnpa, length = 10),
          vessel_rnpa = fix_rnpa(rnpa = vessel_rnpa))] %>%
  .[, .(landed_weight = sum(landed_weight, na.rm = T),
        value = sum(value, na.rm = T)),
    by = .(year_cut, month_cut, eu_rnpa, vessel_rnpa, main_species_group)] 


## ECONOMIC UNIT

annual_eu_landings <- dt %>% 
  .[!acuaculture_production == "SÍ"| 
      !fishing_zone_type == "AGUAS CONTINENTALES" |
      !is.na(eu_rnpa) |
      !is.na(vessel_rnpa)] %>% 
  .[,`:=`(eu_rnpa = fix_rnpa(rnpa = eu_rnpa, length = 10))] %>%
  .[, .(landed_weight = sum(landed_weight, na.rm = T),
        value = sum(value, na.rm = T)),
    by = .(year_cut, eu_rnpa, main_species_group)] 

monthly_eu_landings <- dt %>% 
  .[!acuaculture_production == "SÍ"| 
      !fishing_zone_type == "AGUAS CONTINENTALES" |
      !is.na(eu_rnpa) |
      !is.na(vessel_rnpa)] %>% 
  .[,`:=`(eu_rnpa = fix_rnpa(rnpa = eu_rnpa, length = 10))] %>%
  .[, .(landed_weight = sum(landed_weight, na.rm = T),
        value = sum(value, na.rm = T)),
    by = .(year_cut, month_cut, eu_rnpa, main_species_group)] 


saveRDS(object = annual_vessel_landings,
        file = here("data", "mex_landings", "clean", "mex_annual_landings_by_vessel.rds"))

saveRDS(object = monthly_vessel_landings,
        file = here("data", "mex_landings", "clean", "mex_monthly_landings_by_vessel.rds"))

saveRDS(object = annual_eu_landings,
        file = here("data", "mex_landings", "clean", "mex_annual_landings_by_eu.rds"))

saveRDS(object = monthly_eu_landings,
        file = here("data", "mex_landings", "clean", "mex_monthly_landings_by_eu.rds"))



