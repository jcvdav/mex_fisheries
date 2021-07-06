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

## Define functions we'll use
# String-fixing function
str_fix <- function(x) {
  x <- str_to_upper(x)        # String to upper
  x <-
    str_trim(x)            # Trim leading and trailing whites paces
  x <- str_squish(x)          # Squish repeated white spaces
  return(x)                   # Return clean string
}

# Design speed function
design_speed <- function(engine_power_hp) {
  engine_power_kwh <- (engine_power_hp / 1.34102)                           # Convert to kwh
  10.4818 + (1.2e-3 * engine_power_kwh) - (3.84e-8 * engine_power_kwh ^ 2)  # Calculate design speed
}

## Load data  ###############################################################################################################################################
# Maximum daily liters for each engine size and fuel type
mdl_raw <-
  read_csv(file.path(project_path, "raw_data", "maximum_daily_liters.csv"))

# The data are in an excel file, which contains three worksheets
excel_data_file <- file.path(project_path,"raw_data","ANEXO-DGPPE-147220","ANEXO SISI 147220 - EmbarcacionesMenores.xlsx")

# List of assets are on sheet 1
ss_assets_raw <- read_excel(
  path = excel_data_file,
  sheet = 1,
  col_types = c("text", "text", "text", "text", "text", "text", "text", "text", "text", "text",
                "text", "text", "text", "text", "text", "text", "numeric", "numeric", "text", "text",
                "text", "numeric", "text", "text", "text", "text", "text"))

## Define Engine Power bins
# Create two data frames, one for each fuel type

mdl_diesel <- mdl_raw %>% 
  filter(fuel_type == "diesel")

mdl_gasoline <- mdl_raw %>% 
  filter(fuel_type == "gasoline")

# Define unique vector of engine power bins
engine_power_bins_diesel <- c(0, unique(mdl_diesel$engine_power_hp))                            # We add a 0 for those engines < smallest category
engine_power_bins_gasoline <- c(0, unique(mdl_gasoline$engine_power_hp))                            # We add a 0 for those engines < smallest category

## Selections  ###############################################################################################################################################
# In this section we select the columns we wish to keep
# from each of the data sets. We also clean column names
# and then rename them into English. Whenever relevant,
# the values stored in them are also converted into English

# Vessel engines
ss_vessel_registry <- ss_assets_raw %>%
  clean_names() %>%                                                                      # Clean column names
  filter(estatus == "ACTIVO") %>%
  rename(                                                                                # Start renaming columns we'll keep
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
    engine_power_hp = potencia) %>% 
  distinct() %>% 
  mutate(
    engine_power_bin_diesel_hp = map_dbl(engine_power_hp,                                       # Find the matching bin from the regulation
                                         ~ {max(engine_power_bins_diesel[engine_power_bins_diesel <= .x])}),
    engine_power_bin_gasoline_hp = map_dbl(engine_power_hp,                                       # Find the matching bin from the regulation
                                           ~ {max(engine_power_bins_gasoline[engine_power_bins_gasoline <= .x])}),
    engine_power_bin_hp = ifelse(fuel_type == "Diesel", engine_power_bin_diesel_hp, engine_power_bin_gasoline_hp),
    design_speed_kt = design_speed(engine_power_hp),                                              # Calculate the engine's design speed
    # vessel_name = furrr::future_map_chr(vessel_name, normalize_shipname),
    vessel_rnpa = fix_rnpa(vessel_rnpa),
    sfc_gr_kwh = 240) %>%                                                     #
  filter(engine_power_hp > 0) %>% 
  drop_na(eu_rnpa, vessel_rnpa, engine_power_hp) %>% 
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
    engine_power_bin_hp,
    design_speed_kt
  )


## Export data  ###############################################################################################################################################

# Save csv for gogole cloud bucket
write.csv(x = ss_vessel_registry,
          file = file.path(project_path, "processed_data", "MEX_VESSEL_REGISTRY", "small_scale_vessel_registry.csv"),
          row.names = F)

# END OF SCRIPT ###############################################################################################################################################