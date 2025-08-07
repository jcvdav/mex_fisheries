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

source(here("scripts", "00_setup.R"))

## Load data  ###############################################################################################################################################

# The data are in an excel file, which contains three worksheets
excel_data_file <-
  here(
    "data",
    "mex_vessel_registry",
    "raw",
    "ANEXO-DGPPE-147220",
    "ANEXO SISI 147220 - EmbarcacionesMenores.xlsx"
  )

# List of assets are on sheet 1
ss_assets_raw <- read_excel(
  path = excel_data_file,
  sheet = 1,
  col_types = c(
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
    "text",
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
    "text",
    "text",
    "text",
    "numeric",
    "text",
    "text",
    "text",
    "text",
    "text"
  )
)


## Selections  ###############################################################################################################################################
# In this section we select the columns we wish to keep
# from each of the data sets. We also clean column names
# and then rename them into English. Whenever relevant,
# the values stored in them are also converted into English

# Vessel engines
ss_vessel_registry <- ss_assets_raw %>%
  clean_names() %>%                                                                      # Clean column names
  # filter(estatus == "ACTIVO") %>%
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
    hull_material = material_casco,
    vessel_length_m = eslora,
    vessel_gross_tonnage = cap_carga,
    fuel_type = combustible,
    brand = marca,
    model = modelo,
    serial_number = serie,
    engine_power_hp = potencia
  ) %>%
  distinct() %>%
  mutate_at(vars(brand, model), str_fix) %>%                                                    # Fix all string variables for engines
  mutate(
    fuel_type = case_when(
      fuel_type == "GASOLINA" ~ "Gasoline",
      fuel_type == "DIESEL" ~ "Diesel",
      T ~ NA_character_
    ),
    design_speed_kt = design_speed(engine_power_hp),
    # Calculate the engine's design speed
    # vessel_name = furrr::future_map_chr(vessel_name, normalize_shipname),
    sfc_gr_kwh = 240
  ) %>%                                                     #
  filter(engine_power_hp > 0) %>%
  drop_na(eu_rnpa, vessel_rnpa, engine_power_hp) %>%
  mutate(engine_power_kw = 0.7457 * engine_power_hp) %>% 
  select(
    eu_rnpa,
    economic_unit,
    vessel_rnpa,
    vessel_name,
    owner_rnpa,
    owner_name,
    hull_identifier,
    hull_material,
    contains("vessel_"),
    engine_power_hp,
    engine_power_kw,
    design_speed_kt,
    brand,
    model,
    fuel_type
  ) %>%
  mutate(fleet = "small scale") %>%
  drop_na(vessel_rnpa) %>%
  distinct() %>%
  group_by(vessel_rnpa) %>%
  mutate(n = n()) %>%
  ungroup() %>%
  filter(n == 1) %>%
  select(-n)


## Export data  ###############################################################################################################################################

# Save csv for gogole cloud bucket
saveRDS(ss_vessel_registry,
  file = here(
    "data",
    "mex_vessel_registry",
    "clean",
    "small_scale_vessel_registry.rds"
  )
)

# END OF SCRIPT ###############################################################################################################################################