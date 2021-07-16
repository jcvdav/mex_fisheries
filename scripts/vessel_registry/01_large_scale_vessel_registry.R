######################################################
#               create vessel registry               #
######################################################

#### Set up  ###############################################################################################################################################

# Load packages
library(here)
library(startR)
library(janitor)
library(readxl)
library(furrr)
library(tidyverse)


## Load data  ###############################################################################################################################################
# Maximum daily liters for each engine size and fuel type
mdl_raw <-
  read_csv(file.path(project_path, "raw_data", "maximum_daily_liters.csv")) %>% 
  filter(fuel_type == "diesel")

# The data are in an excel file, which contains three worksheets
excel_data_file <- file.path(project_path,"raw_data","ANEXO-DGPPE-147220","ANEXO SISI 147220 - EmbarcacionesMayores.xlsx")

# List of assets are on sheet 1
ls_assets_raw <- read_excel(
  path = excel_data_file,
  skip = 6,
  sheet = 1,
  col_types = c("skip", "text", "text", "text", "text", "text", "text", "text", "text", "text",         # Ah, the joy of specifying column types
                "text", "text", "text", "text", "text", "text", "text", "text", "numeric", "numeric",
                "numeric", "numeric", "numeric", "text", "text", "text", "text", "numeric", "numeric",
                "numeric", "numeric", "numeric", "numeric", "numeric", "text", "text", "text", "text"))

# List of large-scale vessel engines are on sheet 2
vessel_engines_ls_raw <- read_excel(
  path = excel_data_file,
  sheet = 2,
  col_types = c("skip", "text", "text", "text", "text", "numeric", "text"))

# Define a unique vector of engine power bins
engine_power_bins <- c(0, unique(mdl_raw$engine_power_hp))                            # We add a 0 for those engines < smallest category

## Selections  ###############################################################################################################################################
# In this section we select the columns we wish to keep
# from each of the data sets. We also clean column names
# and then rename them into English. Whenever relevant,
# the values stored in them are also converted into English

# Vessel engines
vessel_engines <- vessel_engines_ls_raw %>%
  clean_names() %>%                                                                      # Clean column names
  rename(                                                                                # Start renaming columns we'll keep
    vessel_rnpa = rnpa_emb_mayor,
    brand = marca,
    model = modelo,
    serial_number = serie,
    engine_power_hp = potencia,
    main_engine = principal) %>%
  mutate(main_engine = main_engine == "SI") %>% 
  mutate_at(vars(brand, model), str_fix) %>%                                             # Fix all string variables
  group_by(vessel_rnpa) %>%                                                              # Group by vessel and engine type
  mutate(
    engine_power_bin_hp = map_dbl(engine_power_hp,                                       # Find the matching bin from the regulation
                                  ~ {max(engine_power_bins[engine_power_bins <= .x])}),
    design_speed_kt = design_speed(engine_power_hp)                                      # Calculate the engine's design speed
  ) %>% 
  select(
    vessel_rnpa,
    engine_power_hp,
    engine_power_bin_hp,
    design_speed_kt
  ) %>%
  distinct()

# Clean assets
plan("multisession")                   # It's faster to run in parallel

ls_assets <- ls_assets_raw %>%
  clean_names() %>%                   # Clean column names
  rename(                             # Start renming columns we'll keep
    eu_rnpa = rnpa_8,
    economic_unit = unidad_economica,
    vessel_rnpa = rnpa_10,
    vessel_name = activo,
    vessel_type = uso,
    owner_rnpa = rnpa_13,
    owner_name = propietario,
    hull_identifier = matricula,
    home_port = puerto,
    captain_num = patron,
    engineer_num = motorista,
    s_fisher_num = pescador_esp,
    fisher_num = pescador,
    construction_year = ano_construccion,
    hull_material = material_casco,
    preservation_system = sistema_conservacion,
    gear_type = arte_pesca,
    target_species = pesqueria,
    vessel_length_m = eslora,
    vessel_beam_m = manga,
    vessel_height_m = puntal,
    vessel_draft_m = calado,
    vessel_gross_tonnage = cap_carga,
    detection_gear = equipo_deteccion
  ) %>%                                                    ### REVIEW SPECIES ASSIGNMENT (TO BETTER-MATCH DPC)
  filter(estatus == "ACTIVO") %>%
  select(
    eu_rnpa,
    economic_unit,
    vessel_rnpa,
    vessel_name,
    owner_rnpa,
    owner_name,
    hull_identifier,
    target_species,
    home_port,
    construction_year,
    hull_material,
    preservation_system,
    gear_type,
    detection_gear,
    contains("vessel_"),
    contains("_num")
  ) %>%
  distinct() %>%
  mutate(
    target_species = case_when(
      str_detect(target_species, "ATÚN") ~ "tuna",                                         # Partial tuna matches are tuna
      str_detect(target_species, "SARDINA") ~ "sardine",                                   # Partial sardine matches that don't contain tuna are sardine
      target_species == "CAMARÓN | CAMARÓN" ~ "shrimp",                                    # Double shrimp matches are shrimp
      str_detect(target_species, "CAMARÓN") & target_species != "CAMARÓN" ~ "shrimp plus", # Matching shrimp and anything else is shrimp plus
      target_species == "CAMARÓN" ~ "shrimp",                                              # Anything mtching exactly shrimp is shrimp
      T ~ "any"),                                                                          # Anything left is any fishery
    # vessel_name = furrr::future_map_chr(vessel_name, normalize_shipname),
    sfc_gr_kwh = case_when(
      vessel_length_m < 12 ~ 240,                                                          # Vessels smaller than 12 m have an SFC of 240 gr / kWH
      between(vessel_length_m, 12, 24) ~ 220,                                              # Vessels between 12 and 24 have an SFC of 220 gr / kWH
      vessel_length_m > 24 ~ 180)) %>%                                                     # Vessels larger than 24 m have an SFC of 180 gr / kWH
  drop_na(eu_rnpa, vessel_rnpa)

plan("sequential")

## Combine tables  ###############################################################################################################################################
ls_vessel_registry <- ls_assets %>%                            # Take the assets table
  left_join(vessel_engines, by = "vessel_rnpa") %>%      # And add its engine info
  drop_na(engine_power_hp) %>%                           # Drop vessels for which we don't have engine info
  filter(between(vessel_length_m, 10, 100))


## Export data  ###############################################################################################################################################

# Save csv for gogole cloud bucket
write.csv(x = ls_vessel_registry,
          file = file.path(project_path, "processed_data", "MEX_VESSEL_REGISTRY", "large_scale_vessel_registry.csv"),
          row.names = F)

# END OF SCRIPT ###############################################################################################################################################