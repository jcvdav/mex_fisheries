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
urchin <- st_read(here("data", "concesiones", "raw", "TURF_Sea_Urchin_2022")) %>% 
  st_zm(drop = T) %>% 
  st_transform("EPSG:4326") %>% 
  select(name = Name, 
         management = TURF)

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
clean_urchin <- urchin %>% 
  mutate(
    eu_rnpa = case_when(
      name == "AGROINDUSTRIA PESQUERA ISLAS CORONADO NORTE S. DE R.L. DE C.V." ~ "0203009899",
      name == "ASOCIACION ARVI, S.P.R. DE R.L." ~ "0203009105",
      name == "ASOCIACIÓN EJIDAL JAMAR, S.P.R. DE R.L." ~ "0203126487",
      name == "ASOCIACION PESQUERA ESPECIALIZADA EL ROSARIO, S.P.R. DE R.L." ~ "0203120503",
      name == "ASOCIACIÓN PESQUERA MORTERA DE LEYVA, S.P.R DE  R.L." ~ "0203009949",
      name == "ASOCIACIÓN PESQUERA REGASA NUM. 2, S.P.R. DE R.L." ~ "0203004726",
      name == "BAHIA TODOS SANTOS S.P.R. DE R.L." ~ "0203009451",
      name == "BK DEL PACIFICO, S.P.R. DE R.L." ~ "0203015748",
      name == "BUZOS Y PESCADORES DEL EJIDO CORONEL ESTEBAN CANTU S.P.R. DE R.L." ~ "0203008149",
      name == "CARMELINA REYES OSORIO" ~ NA_character_,
      name == "ERICEROS DE LA COSTA DEL PACIFICO, S.P.R. DE R.L." ~ "0203009527",
      name == "ERIPAC, S.A. DE C.V." ~ "0203004866",
      name == "GRUPO JAUREGUI HERNANDEZ, S.P.R. DE R.L." ~ "0203126602",
      name == "HERMANOS VIERA, S.P.R. DE R.L." ~ "0203008875",
      name == "ISLA SAN GERONIMO, S.P.R. DE R.I." ~ "0203126974",
      name == "KACHIGI S.P.R. DE R.I." ~ "0203126982",
      name == "OSTIONES GUERRERO S.A. DE C.V." ~ "0203008578",
      name == "PESCADORES EL CHUTE, S.P.R.  DE R" ~ "0203010384",
      name == "PESCADORES RIBEREÑOS DE PUERTO NUEVO, S.P.R. DE R.L." ~ "0203014717",
      name == "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA, S.A. DE C.V." ~ "0203008990",
      name == "PRODUCTORES DEL VALLE TRANQUILO, S.P.R. DE R.L." ~ "0203011887",
      name == "PRODUCTORES PESQUEROS DE BAJA CALIFORNIA, S. P. R. DE R. L." ~ "0203011499",
      name == "PRODUCTOS DEL MAR CATALINA, S. DE R.L. DE C.V." ~ "0203126677",
      name == "PRODUCTOS DEL MAR COSTA OESTE, S. P. R. DE R. L." ~ "0203009279",
      name == "PRODUCTOS MARINOS ERENDIRA, S.P.R. DE R.L." ~ "0203127311",
      name == "ROBERTO JUAN CAMACHO TAPIA" ~ "0203014691",
      name == "RODOLFO NUÑO GARCIA" ~ "0203002001",
      name == "ROEZA, S.P.R. DE R.L." ~ "0203014550",
      name == "S.C.P.P. BUZOS Y PESC. BAHIA ENSENADA, S.C.L." ~ "0203010491",
      name == "S.C.P.P. BUZOS Y PESCADORES DE LA BAJA CALIFORNIA" ~ "0301000089",
      name == "S.C.P.P. ENSENADA, S.C.L." ~ "0203000302",
      name == "S.C.P.P. PESCADORES NACIONALES DE ABULÓN, S.C. DE R.L." ~ "0203000278",
      name == "S.E.P.P.E. JUAN ESCUTIA S.P.R. DE R.L." ~ "0203000530",
      name == "S.P.R. PUNTA CANOAS, S. DE R.L. DE C.V." ~ "0203010715",
      name == "SALVADOR VALENCIA MEDINA" ~ "0203002811",
      name == "SEA URCHIN PACIFIC S.P.R. DE R.L." ~ "0203012646",
      name == "SUR PACIFIC, S.P.R. DE R.L." ~ "0203011457",
      name == "U.P.P. PESCADORES RIBEREÑOS DE BAJA CALIFORNIA, S.P.R. DE R.L." ~ "0203007901",
      name == "U.P.P.E. EL PUERTO DE SANTO TOMAS, S.P.R. DE R.L." ~ "0203015128",
      name == "UNIDAD DE PRODUCCIÓN PESQUERA  \"EMEJA\", S.P.R. DE R.L." ~ "0203004577",
      name == "UNIDAD DE PRODUCCIÓN PESQUERA EJIDAL AJUSCO, S.P.R. DE R.L." ~ "0203008826",
      name == "UNIDAD DE PRODUCTORES EJIDALES EL CONSUELO, S.P.R. DE R.L." ~ "0203008586",
      name == "UNION BUZOS Y PESCADORES EL PROGRESO, S.P.R. DE R.L." ~ "0203008610",
      name == "UNIÓN DE PESCADORES BUZOS DE LA COSTA OCC. DE BAJA CALIF., S. DE R.L. DE C.V." ~ "0203005673",
      name == "UNION DE PESCADORES RIBEREÑOS HERMANOS SANCHEZ, S.P.R. DE R.L. DE C.V." ~ "0203017716",
      name == "VINATACOT, S.P.R. DE R.L." ~ "0203009956",
      name == "ZUAREV S.P.R. DE R.L." ~ "0203126552")) %>% 
  st_cast("POLYGON") %>% 
  st_make_valid() %>% 
  rename(eu_name = name) %>% 
  group_by(eu_name, eu_rnpa, management) %>% 
  summarize(a = 1) %>% 
  ungroup() %>% 
  select(-a) %>% 
  mutate(fishery = "urchin")

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
st_write(obj = clean_urchin,
         dsn = here("data", "concesiones", "processed", "urchin_permit_and_concessions_polygons.gpkg"),
         delete_dsn = T)