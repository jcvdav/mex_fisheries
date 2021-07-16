
library(data.table)
library(tidyverse)


files <- list.files(path = file.path(project_path, "processed_data", "MEX_VESSEL_REGISTRY"), pattern = "scale", full.names = T)

vessel_registry <- map_dfr(files,
                           fread) %>% 
  mutate(vessel_rnpa = fix_rnpa(vessel_rnpa)) %>%
  distinct()

fwrite(vessel_registry,
       file.path(project_path, "processed_data", "MEX_VESSEL_REGISTRY", "complete_vessel_registry.csv"),
       append = F)

system("date >> scripts/vessel_registry/registry.log")
