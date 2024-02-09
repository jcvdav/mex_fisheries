################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Stuart Fulton gave me these data, I'm just cleaning them
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  here,
  janitor,
  data.table,
  tidyverse
)

# Load and define functions ----------------------------------------------------
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
           year_cut = as.numeric(year_cut),
           landed_weight = as.numeric(landed_weight),
           live_weight = as.numeric(live_weight),
           value = as.numeric(value))
}

# Identify files ---------------------------------------------------------------
files <- list.files(path = here("data", "mex_landings", "raw", "CONAPESCA_Avisos_2000-2019"),
                    pattern = "*\\.csv",
                    full.names = T)

## PROCESSING ##################################################################

# Load data and apply filters --------------------------------------------------
dt <- map_dfr(files, my_read) %>% 
  as_tibble() %>% 
  mutate(eu_rnpa = fix_rnpa(rnpa = eu_rnpa, length = 10),
         vessel_rnpa = fix_rnpa(rnpa = vessel_rnpa),
         acuaculture_production = case_when(acuaculture_production == "" ~ NA_character_,
                                            T ~ acuaculture_production))

## EXPORT ######################################################################
# Export file ------------------------------------------------------------------
saveRDS(object = dt,
        file = here("data", "mex_landings", "clean", "mex_conapesca_avisos_2000_2019.rds"))

