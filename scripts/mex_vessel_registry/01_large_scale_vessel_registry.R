######################################################
#               create vessel registry               #
######################################################

#### Set up  ###############################################################################################################################################

# Load packages
library(here)
library(startR)
library(janitor)
library(readxl)
library(tidyverse)

# Load functions -
source(here("scripts", "00_setup.R"))


## Load data  ###############################################################################################################################################

# The data are in an excel file, which contains three worksheets
excel_data_file <-
  here(
    "data",
    "mex_vessel_registry",
    "raw",
    "ANEXO-DGPPE-147220",
    "ANEXO SISI 147220 - EmbarcacionesMayores.xlsx"
  )

# List of assets are on sheet 1
ls_assets_raw <- read_excel(
  path = excel_data_file,
  skip = 6,
  sheet = 1,
  col_types = c(
    "skip",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    # Ah, the joy of specifying column types
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "numeric",
    "numeric",
    "numeric",
    "numeric",
    "numeric",
    "text",
    "text",
    "text",
    "text",
    "numeric",
    "numeric",
    "numeric",
    "numeric",
    "numeric",
    "numeric",
    "numeric",
    "text",
    "text",
    "text",
    "text"
  )
)

# List of large-scale vessel engines are on sheet 2
vessel_engines_ls_raw <- read_excel(
  path = excel_data_file,
  sheet = 2,
  col_types = c("skip", "text", "text", "text", "text", "numeric", "text")
)

## Selections  ###############################################################################################################################################
# In this section we select the columns we wish to keep
# from each of the data sets. We also clean column names
# and then rename them into English. Whenever relevant,
# the values stored in them are also converted into English

# Vessel engines
vessel_engines <- vessel_engines_ls_raw |>
  clean_names() |>                                                                      # Clean column names
  rename(
    # Start renaming columns we'll keep
    vessel_rnpa = rnpa_emb_mayor,
    brand = marca,
    model = modelo,
    serial_number = serie,
    engine_power_hp = potencia,
    main_engine = principal
  ) |>
  drop_na(vessel_rnpa, engine_power_hp) |>
  mutate(engine_type = ifelse(main_engine == "SI", "main", "auxiliary")) |>
  mutate_at(vars(brand, model), str_fix) |>                                             # Fix all string variables
  select(vessel_rnpa,
         engine_type,
         engine_power_hp,
         brand,
         model) |>
  mutate(engine_power_hp = ifelse(engine_power_hp < 15, NA_real_, engine_power_hp)) |> 
  distinct() |>
  # IF it has more than one auxiliary or more than one main, we add their total power
  group_by(vessel_rnpa,
           engine_type) |> 
  summarize(engine_power_hp = sum(engine_power_hp),
            n_engines = n(),
            .groups = "drop") |> 
  pivot_wider(names_from = engine_type,
              values_from = c(engine_power_hp, n_engines),
              names_glue = "{engine_type}_{.value}") |> 
  select(vessel_rnpa,
         main_engines_n = main_n_engines,
         main_engine_power_hp,
         auxiliary_engines_n = auxiliary_n_engines,
         auxiliary_engine_power_hp) |> 
  replace_na(replace = list(main_engines_n = 0,
                            auxiliary_engines_n = 0)) |> 
  mutate(auxiliary_engine_power_hp = ifelse(auxiliary_engines_n == 0, 0, auxiliary_engine_power_hp))

# Clean assets
ls_assets <- ls_assets_raw |> 
  clean_names() |>                    # Clean column names
  rename(
    # Start renaming columns we'll keep
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
  ) |> 
  drop_na(eu_rnpa, vessel_rnpa) |> 
  # filter(estatus == "ACTIVO") |>
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
  ) |>
  distinct() |>
  mutate(
    # Target species
    target_finfish = 1 * str_detect(target_species, "ESCAMA"),
    target_sardine = 1 * str_detect(target_species, "SARDINA"),
    target_shark = 1 * str_detect(target_species, "TIBURÓN"),
    target_shrimp = 1 * str_detect(target_species, "CAMARÓN"),
    target_tuna = 1 * str_detect(target_species, "ATÚN"),
    target_other = 1 * (target_finfish == 0 & target_sardine == 0 & target_shark == 0 & target_shrimp == 0 & target_tuna == 0),
    # Gears employed
    gear_trawler = 1 * str_detect(gear_type, "ARRASTRE"),
    gear_purse_seine = 1 * str_detect(gear_type, "CERCO"),
    gear_longline = 1 * str_detect(gear_type, "PALANGRE"),
    gear_other = 1 * (gear_trawler == 0 & gear_purse_seine == 0 & gear_longline == 0),
    # There are three vessels that are > 250 m (2480 2595, and 16076). I suspect these are errors in units, but will need to be made NA for now
    # Similarly, there are 27 vessels with length = 0, so we'll make those NAs.
    vessel_length_m = case_when(vessel_length_m > 250 ~ NA_real_,
                                vessel_length_m == 0 ~ NA_real_,
                                T ~ vessel_length_m)
  )
  

# plan("sequential")

## Combine tables  ###############################################################################################################################################
ls_vessel_registry <-
  ls_assets |>                      # Take the assets table
  left_join(vessel_engines, by = "vessel_rnpa") |>      # And add its engine info
  # filter(between(vessel_length_m, 5, 100)) |>
  mutate(fuel_type = "Diesel",
         fleet = "large scale")

ls_vessel_registry_clean <- ls_vessel_registry  |>
  select(
    eu_rnpa,
    economic_unit,
    vessel_rnpa,
    vessel_name,
    owner_rnpa,
    owner_name,
    hull_identifier,
    contains("target_"),
    contains("gear_"),
    state,
    home_port,
    construction_year,
    hull_material,
    preservation_system,
    detection_gear,
    contains("vessel_"),
    contains("_num"),
    main_engines_n,
    main_engine_power_hp,
    auxiliary_engines_n,
    auxiliary_engine_power_hp,
    fuel_type,
    fleet
  )



## Export data  ###############################################################################################################################################

# Save rds for google cloud bucket
saveRDS(ls_vessel_registry_clean,
  file = here(
    "data",
    "mex_vessel_registry",
    "clean",
    "large_scale_vessel_registry.rds"
  )
)

# END OF SCRIPT ###############################################################################################################################################