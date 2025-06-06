######################################################
#title#
######################################################
#
# Purpose
#
######################################################

# Packages
library(here)
library(data.table)
library(tidyverse)

source(here("scripts", "00_setup.R"))


files <-
  list.files(
    path = here("data", "mex_vessel_registry", "clean"),
    pattern = "scale",
    full.names = T
  )

vessel_registry <- map_dfr(files,
                           fread) %>%
  rename(eu_name = economic_unit) %>% 
  mutate(vessel_rnpa = fix_rnpa(vessel_rnpa),
         eu_name = clean_eu_names(eu_name),
         eu_rnpa = fix_rnpa(eu_rnpa, 10)) %>%
  distinct() %>%
  select(-target_species)

fwrite(
  x = vessel_registry,
  file = here(
    "data",
    "mex_vessel_registry",
    "clean" ,
    "complete_vessel_registry.csv"
  ),
  append = F
)
