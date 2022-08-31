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
  select(
    vessel_rnpa,
    engine_power_hp,
    brand,
    model
  ) %>%
  drop_na(vessel_rnpa) %>% 
  distinct() %>% 
  mutate(engine_power_hp = ifelse(engine_power_hp < 15, NA_real_, engine_power_hp))

# Clean assets
# plan("multisession")                   # It's faster to run in parallel

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
    state = entidad,
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
  # filter(estatus == "ACTIVO") %>%
  select(
    eu_rnpa,
    economic_unit,
    vessel_rnpa,
    vessel_name,
    owner_rnpa,
    owner_name,
    hull_identifier,
    target_species,
    state,
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
    tuna = 1 * str_detect(target_species, "ATÚN"),
    sardine = 1 * str_detect(target_species, "SARDINA"),
    shrimp = 1 * str_detect(target_species, "CAMARÓN"),
    others = 1 * (tuna == 0 & sardine == 0 & shrimp == 0),
    # vessel_name = furrr::future_map_chr(vessel_name, normalize_shipname),
    sfc_gr_kwh = case_when(
      vessel_length_m < 12 ~ 240,                                                          # Vessels smaller than 12 m have an SFC of 240 gr / kWH
      between(vessel_length_m, 12, 24) ~ 220,                                              # Vessels between 12 and 24 have an SFC of 220 gr / kWH
      vessel_length_m > 24 ~ 180)) %>%                                                     # Vessels larger than 24 m have an SFC of 180 gr / kWH
  drop_na(eu_rnpa, vessel_rnpa)

# plan("sequential")

## Combine tables  ###############################################################################################################################################
ls_vessel_registry <- ls_assets %>%                      # Take the assets table
  left_join(vessel_engines, by = "vessel_rnpa") %>%      # And add its engine info
  filter(between(vessel_length_m, 10.5, 100)) %>% 
  mutate(fuel_type = "Diesel",
         fleet = "large scale")

engine_power_model <- lm(log(engine_power_hp) ~ log(vessel_length_m) + shrimp + tuna + sardine + others, data = ls_vessel_registry)

ls_vessel_registry_clean <- ls_vessel_registry  %>% 
  mutate(imputed_engine_power = is.na(engine_power_hp),
         new_hp = exp(predict(engine_power_model, newdata = .)),
         engine_power_hp = coalesce(engine_power_hp, new_hp),
         design_speed_kt = design_speed(engine_power_hp)) %>%                             # Calculate the engine's design speed
  select(-new_hp) %>%
  group_by(vessel_rnpa) %>%                                                              # Group by vessel and engine type
  mutate(
    engine_power_bin_hp = map_dbl(engine_power_hp,                                       # Find the matching bin from the regulation
                                  ~ {max(engine_power_bins[engine_power_bins <= .x])})
  ) %>% 
  ungroup() %>% 
  select(
    eu_rnpa,
    economic_unit,
    vessel_rnpa,
    vessel_name,
    owner_rnpa,
    owner_name,
    hull_identifier,
    target_species,
    tuna,
    sardine,
    shrimp,
    others,
    state,
    home_port,
    construction_year,
    hull_material,
    preservation_system,
    gear_type,
    detection_gear,
    contains("vessel_"),
    contains("_num"),
    sfc_gr_kwh,
    engine_power_hp,
    imputed_engine_power,
    engine_power_bin_hp,
    design_speed_kt,
    brand,
    model,
    fuel_type,
    fleet)
  


## Export data  ###############################################################################################################################################

# Save csv for gogole cloud bucket
write.csv(x = ls_vessel_registry_clean,
          file = file.path(project_path, "processed_data", "MEX_VESSEL_REGISTRY", "large_scale_vessel_registry.csv"),
          row.names = F)

system("date >> scripts/vessel_registry/ls.log")

# END OF SCRIPT ###############################################################################################################################################