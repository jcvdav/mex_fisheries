################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Build data for Lili
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(
  here,
  readxl,
  tidyverse
)

# Load data --------------------------------------------------------------------
# Load landings data
landings <- readRDS(here("data", "mex_landings", "clean", "mex_landings_2000_2022.rds"))

coop_info <- read_excel(path = here("../resilient_ssf", "data", "raw", "Cooperativas- UnidadesEconomicas2020.xlsx"),
                        sheet = "cooperativas") %>% 
  janitor::clean_names() %>%
  select(eu_rnpa = rnpa,
         type = tipo,
         state = estado,
         municipality = municipio,
         full_time_employees = emp_planta_number_of_members,
         part_time_employees = emp_eventual,
         n_small_boats = activos_menores,
         n_large_boats = activos_mayores,
         aquaculture_assets = activos_inst_acuicolas) %>%
  mutate(eu_rnpa = fix_rnpa(eu_rnpa, 10)) %>% 
  filter(!eu_rnpa == "0000000000") %>% # Remove those we can't identify
  distinct()

## PROCESSING ##################################################################

# Filter for SSF only ----------------------------------------------------------
filtered_landings <- landings %>% 
  select(year,
         eu_rnpa,
         aquaculture = acuaculture_production,
         main_species_group,
         landed_weight,
         live_weight,
         value) %>% 
  group_by(year, eu_rnpa, aquaculture, main_species_group) %>% 
  summarize(landed_weight = sum(landed_weight),
            live_weight = sum(live_weight),
            value = sum(value)) %>% 
  ungroup() %>% 
  inner_join(coop_info, by = "eu_rnpa")

## VISUALIZE ###################################################################

# X ----------------------------------------------------------------------------
write_csv(x = filtered_landings,
          file = here("data_for_lili.csv"))
