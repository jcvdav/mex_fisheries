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

files <- list.files(path = file.path(data_sets, "mex_fisheries", "mex_vessel_registry", "clean"), pattern = "scale", full.names = T)

vessel_registry <- map_dfr(files,
                           fread) %>% 
  mutate(vessel_rnpa = fix_rnpa(vessel_rnpa)) %>%
  distinct() %>% 
  select(-target_species)

fwrite(vessel_registry,
       file.path(data_sets, "mex_fisheries", "mex_vessel_registry", "clean" ,"complete_vessel_registry.csv"),
       append = F)

system("date >> scripts/vessel_registry/registry.log")
