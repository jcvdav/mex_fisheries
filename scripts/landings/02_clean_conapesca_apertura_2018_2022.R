################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Cleaing data from: https://conapesca.gob.mx/wb/cona/avisos_arribo_cosecha_produccion
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
library(here)
library(readxl)
library(tidyverse)

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
              "coastline")

# Load data --------------------------------------------------------------------
files <- list.files(path = here("data", "mex_landings", "raw", "CONAPESCA_apertura"),
                    pattern = "*.xlsx",
                    full.names = T)

landings_ls <- map_dfr(files, readxl::read_excel, col_types = "text", sheet = "AVISOS DE ARRIBO MAYORES") %>% 
  janitor::clean_names() %>% 
  mutate(fleet = "large_scale")
landings_ss <- map_dfr(files, readxl::read_excel, col_types = "text", sheet = "AVISOS DE ARRIBO MENORES") %>% 
  janitor::clean_names() %>% 
  mutate(fleet = "small_scale")

## PROCESSING ##################################################################

# Rename and filter ------------------------------------------------------------
landings_clean <- rbind(landings_ls,
                        landings_ss) %>% 
  mutate(landed_weight = coalesce(peso_desembarcado_kg, peso_desembarcado),
         live_weight = coalesce(peso_vivo_kg, peso_vivo),
         price = coalesce(precio_por_kilogramo_pesos, precio),
         value = coalesce(valor_pesos, valor),
         landed_weight = as.numeric(landed_weight),
         value = as.numeric(value)) %>% 
  select(state = nombre_estado,
         office_name = nombre_oficina,
         fleet,
         vessel_rnpa = rnp_activo,
         vessel_name = nombre_activo,
         landing_site = nombre_sitio_desembarque,
         eu_rnpa = rnpa_unidad_economica,
         economic_unit = unidad_economica,
         origin = origen,
         fishing_site_name = nombre_lugarcaptura,
         n_vessels = numero_embarcaciones,
         month_cut = mes_corte,
         year_cut = ano_corte,
         period_start = periodo_inicio,
         period_end = periodo_fin,
         period_length = duracion,
         period_effective_days = dias_efectivos,
         fishing_zone_type = tipo_zona,
         acuaculture_production = produccion_acuacultural,
         permit_number = numero_permiso,
         permit_issue_date = fecha_expedicion,
         permit_expiration_date = fecha_vigencia,
         main_species_group = nombre_principal,
         species_key = clave_especie,
         species_name = nombre_especie,
         landed_weight,
         live_weight,
         price,
         value) %>% 
  filter(!fishing_zone_type == "AGUAS CONTINENTALES",
         !is.na(eu_rnpa)) %>% 
  mutate(year_cut = as.numeric(year_cut))

## EXPORT ######################################################################

# Export file  000--------------------------------------------------------------
saveRDS(object = landings_clean,
        file = here("data", "mex_landings", "clean", "mex_conapesca_apertura_2018_2022.rds"))
