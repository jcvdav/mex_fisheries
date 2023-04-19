################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Description
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
library(here)
library(sf)
library(tidyverse)

# Load data --------------------------------------------------------------------
pepino <- st_read(here("data", "concesiones", "raw", "TURF_Sea_Cucumber_2022")) %>% 
  st_zm(drop = T) %>% 
  st_transform("EPSG:4326") %>% 
  select(name = Name, 
         management = TURF)

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
clean_pepino <- pepino %>% 
  mutate(
    name = case_when(
      name == "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA, S.A. DE C.V. 1" ~ "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA, S.A. DE C.V.",
      name == "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA, S.A. DE C.V. 2" ~ "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA, S.A. DE C.V.",
      name == "PRODUCTOS DEL MAR CATALINA, S. DE R.L. DE C.V. 1" ~ "PRODUCTOS DEL MAR CATALINA, S. DE R.L. DE C.V.",
      name == "PRODUCTOS DEL MAR CATALINA, S. DE R.L. DE C.V. 2" ~ "PRODUCTOS DEL MAR CATALINA, S. DE R.L. DE C.V.",
      T ~ name),
    eu_rnpa = case_when(
      name == "ASOCIACION ARVI, S.P.R. DE R.L." ~ "0203009105",
      name == "ASOCIACIÓN PESQUERA MORTERA DE LEYVA, S.P.R DE  R.L." ~ "0203009949",
      name == "ASOCIACIÓN PESQUERA REGASA NUM. 2, S.P.R. DE R.L." ~ "0203004726",
      name == "BAHIA TODOS SANTOS S.P.R. DE R.L." ~ "0203009451",
      name == "BK DEL PACIFICO, S.P.R. DE R.L." ~ "0203015748",
      name == "BUZOS Y PESCADORES DEL EJIDO CORONEL ESTEBAN CANTU S.P.R. DE R.L." ~ "0203008149",
      name == "CALIFORNIA DE SAN IGNACIO, S.C.L." ~ "0313000028",
      name == "ERICEROS DE LA COSTA DEL PACIFICO, S.P.R. DE R.L." ~ "0203009527",
      name == "Grupo Jauregui Hernández, SPR de RL Cangrejo y Pepino" ~ "0203126602",
      name == "HERMANOS VIERA, S.P.R. DE R.L." ~ "0203008875",
      name == "KACHIGI S.P.R. DE R.I." ~ "0203126982",
      name == "PESCADORES EL CHUTE, S.P.R.  DE R.L." ~ "0203010384",
      name == "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA, S.A. DE C.V." ~ "0203008990",
      name == "PESQUERA GRUPO CINCO, S.P.R. DE R.L." ~ "0203009170",
      name == "PRODUCTORES DEL VALLE TRANQUILO, S.P.R. DE R.L." ~ "0203011887",
      name == "PRODUCTORES PESQUEROS DE BAJA CALIFORNIA, S. P. R. DE R. L." ~ "0203011499",
      name == "PRODUCTOS DEL MAR CATALINA, S. DE R.L. DE C.V." ~ "0203126677",
      name == "PRODUCTOS DEL MAR COSTA OESTE, S. P. R. DE R. L." ~ "0203009279",
      name == "Raúl Colin Ortiz Pepino" ~ "0203127444",
      name == "ROBERTO JUAN CAMACHO TAPIA" ~ "0203014691",
      name == "ROEZA, S.P.R. DE R.L." ~ "0203014550",
      name == "S.C.P.P LA PURISIMA, S.C.L." ~ "0301000105",
      name == "S.C.P.P. BAHIA TORTUGAS, S.C. DE R.L." ~ "0301000113",
      name == "S.C.P.P. BUZOS Y PESCADORES DE LA BAJA CALIFORNIA" ~ "0301000089",
      name == "S.C.P.P. EMANCIPACION S.C.L" ~ "0301000097",
      name == "S.C.P.P. ENSENADA, S.C.L." ~ "0203000302",
      name == "S.C.P.P. PESCADORES NACIONALES DE ABULÓN, S.C. DE R.L." ~ "0203000278",
      name == "S.C.P.P. RIBEREÑA LEYES DE REFORMA, S.C. DE R.L." ~ "0313000036",
      name == "S.P.R. PUNTA CANOAS, S. DE R.L. DE C.V." ~ "0203010715",
      name == "Salvador Valencia Medina Pepino" ~ "0203002811",
      name == "Sur Pacific, SPR de RL Pepino y Cangrejo" ~ "0203011457",
      name == "UNIDAD DE PRODUCTORES EJIDALES EL CONSUELO, S.P.R. DE R.L." ~ "0203008586",
      name == "UNION BUZOS  Y PESCADORES EL PROGRESO, S.P.R. DE R.L." ~ "0203008610",
      name == "UNIÓN DE PESCADORES BUZOS DE LA COSTA OCC. DE BAJA CALIF., S. DE R.L. DE C.V." ~ "0203005673",
      name == "Zuarev, SPR de RL Erizo Rojo y Pepino" ~ "0203126552")) %>% 
  st_cast("POLYGON") %>% 
  st_make_valid() %>% 
  rename(eu_name = name) %>% 
  group_by(eu_name, eu_rnpa, management) %>% 
  summarize(a = 1) %>% 
  ungroup() %>% 
  select(-a) %>% 
  mutate(fishery = "sea_cucumber")

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
st_write(obj = clean_pepino,
         dsn = here("data", "concesiones", "processed", "sea_cucumber_permit_and_concessions_polygons.gpkg"),
         delete_dsn = T)
