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
pacman::p_load(
  here,
  sf,
  tidyverse
)

# Load data --------------------------------------------------------------------
lobster_polygons <- st_read(dsn = here("data", "concesiones", "raw", "TURF_Lobster_2022"),
                            layer = "TURF_Lobster_2022_Final") %>% 
  st_zm(drop = T)

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
clean_lobster_polygons <- lobster_polygons %>% 
  select(name = Name, 
         management = TURF) %>% 
  mutate(eu_name = case_when(
    name == "ASOCIACIÓN PESQUERA REGASA NUM. 2, S.P.R. DE R.L." ~ "Asociacion Pesquera Regasa",
    name == "CALIFORNIA DE SAN IGNACIO, S.C.L." ~ "California de San Ignacio",
    name == "EL PABELLON DE SAN QUINTIN S.P.R. DE R.L." ~ "El Pabellon de San Quintin",
    name == "ERICEROS DE LA COSTA DEL PACIFICO, S.P.R. DE R.L." ~ "Ericeros de la costa del Pacifico",
    name == "FISHINGMEX S.P.R. DE R.L." ~ "Fishingmex",
    name == "GRUPO DE PESCADORES RIBEREÑOS, S.P.R. DE R.L." ~ "Grupo de Pescadores Ribereños",
    name == "HERMANOS VIERA, S.P.R. DE R.L." ~ "Hermanos Viera",
    name == "ISLA SAN GERONIMO, S.P.R. DE R.I." ~ "Isla San Geronimo",
    name == "LITORAL DE BAJA CALIFORNIA, S.P.R. DE R.L." ~ "Litoral de Baja California",
    name == "PESCADORES EL CHUTE, S.P.R.  DE R.L." ~ "Pescadores el Chute",
    name == "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA, S.A. DE C.V." ~ "Pescadores y Buzos Riverenos de Manchuria",
    name == "PESQUERA EL TOMATAL, S.P.R. DE R.L." ~ "El Tomatal",
    name == "PESQUERA GORDOS FISHING, S. DE P.R. DE R.L." ~ "Pesqueria Gordos Fishing",
    name == "PESQUERA GRUPO CINCO, S.P.R. DE R.L." ~ "Pesqueria Grupo Cinco",
    name == "PRODUCTORES PESQUEROS DE BAJA CALIFORNIA, S. P. R. DE R. L." ~ "Productores Pesqueros de Baja California",
    name == "ROCAS DE SAN MARTIN, S.P.R. DE R.L." ~ "Roca San Martin",
    name == "ROEZA, S.P.R. DE R.L." ~ "Roeza",
    name == "S.C.P.P LA PURISIMA, S.C.L." ~ "La Purisima",
    name == "S.C.P.P PUNTA ABREOJOS S.C.L." ~ "Punta Abreojos",
    name == "S.C.P.P. BAHIA TORTUGAS, S.C. DE R.L." ~ "Bahia Tortugas",
    name == "S.C.P.P. BUZOS Y PESCADORES DE LA BAJA CALIFORNIA" ~  "Buzos y Pescadores de la Baja California",
    name == "S.C.P.P. DE P. E. ABULONEROS Y LANGOSTEROS, S.C.L." ~ "Abuloneros y Langosteros",
    name == "S.C.P.P. EMANCIPACION S.C.L" ~ "Emancipacion",
    name == "S.C.P.P. ENSENADA, S.C.L." ~ "Ensenada",
    name == "S.C.P.P. GENERAL MELITON ALBAÑEZ, S.C.L." ~ "General Meliton Albanez",
    name == "S.C.P.P. LA SALINA SC DE RL DE CV" ~ "La Salina",
    name == "S.C.P.P. PESCADORES NACIONALES DE ABULÓN, S.C. DE R.L." ~ "Pescadores Nacionales de Abulon",
    name == "S.C.P.P. PUERTO SAN CARLOS, S.C.L." ~ "Puerto San Carlos",
    name == "S.C.P.P. RAFAEL ORTEGA CRUZ, S.C.L." ~ "Rafael Ortega Cruz",
    name == "S.C.P.P. RIBEREÑA LEYES DE REFORMA, S.C. DE R.L." ~ "Riberena Leyes de Reforma",
    name == "S.C.P.P. RIBEREÑOS DE PUERTO CATARINA, S.C. DE R.L. DE C.V." ~ "Riberenos de Puerto Catarina",
    name == "S.C.P.P. TODOS SANTOS, S.C.L." ~ "Todos Santos",
    name == "S.C.P.P. Y ACUICOLA CON PATRIMONIO EN EL MAR, S.C.L." ~ "Patrimonio en el Mar",
    name == "S.P.R. PUNTA CANOAS, S. DE R.L. DE C.V." ~ "Punta Canoas",
    name == "SEA URCHIN PACIFIC S.P.R. DE R.L." ~ "Sea Urchin Pacific",
    name == "Soc. Cooperativa Progreso de Produccion Pesquera S.C. de R.L" ~ "Progreso",
    name == "U.P.P. AUTENTICOS PESCADORES MORRO ROSARITO, S. DE R.L. DE C.V." ~ "Autenticos Pescadores Morro Rosarito",
    name == "U.P.P. PESCADORES RIBEREÑOS DE BAJA CALIFORNIA, S.P.R. DE R.L." ~ "Pescadores Riberenos de Baja California",
    name == "UNION DE PESCADORES BUZOS DE LA COSTA OCCIDENTAL DE BC, S DE RL DE CV" ~ "Union de Pescadores Buzos de la Costa Occidental de BC")) %>% 
  st_cast("POLYGON") %>% 
  st_make_valid() %>% 
  group_by(eu_name, management) %>% 
  summarize(a = 1) %>% 
  ungroup() %>% 
  select(-a)

# Missing
Jauregui_Hernandez <- filter(clean_lobster_polygons, eu_name == "Pescadores el Chute")

final <- clean_lobster_polygons %>% 
  bind_rows(Jauregui_Hernandez) %>%
  mutate(
    eu_rnpa = case_when(
      eu_name == "Abuloneros y Langosteros" ~ "0203002829",
      eu_name == "Asociacion Pesquera Regasa" ~ "0203004726",
      eu_name == "Autenticos Pescadores Morro Rosarito" ~ "0203008198",
      eu_name == "Bahia Tortugas" ~ "0301000113",
      eu_name == "Buzos y Pescadores de la Baja California" ~ "0301000089",
      eu_name == "California de San Ignacio" ~ "0313000028",
      eu_name == "El Pabellon de San Quintin" ~ "0203017827",
      eu_name == "Emancipacion" ~ "0301000097",
      eu_name == "Ensenada" ~ "0203000302",
      eu_name == "Ericeros de la costa del Pacifico" ~ "0203009527",
      eu_name == "Fishingmex" ~ "0203017157",
      eu_name == "General Meliton Albanez" ~ "0305000028",
      eu_name == "Grupo de Pescadores Ribereños" ~ "0203009261",
      eu_name == "Hermanos Viera" ~ "0203008875",
      eu_name == "Isla San Geronimo" ~ "0203126974",
      eu_name == "Jauregui Hernandez" ~ "0203126602",
      eu_name == "La Purisima" ~ "0301000105",
      eu_name == "La Salina" ~ "0203009535",
      eu_name == "Litoral de Baja California" ~ "0203008305",
      eu_name == "Patrimonio en el Mar" ~ "0203006168",
      eu_name == "Pescadores el Chute" ~ "0203010384",
      eu_name == "Pescadores Nacionales de Abulon" ~ "0203000278",
      eu_name == "Pescadores Riberenos de Baja California" ~ "0203007901",
      eu_name == "Pescadores y Buzos Riverenos de Manchuria" ~ "0203008990",
      eu_name == "El Tomatal" ~ "0203016878",
      eu_name == "Pesqueria Gordos Fishing" ~ "0203017363",
      eu_name == "Pesqueria Grupo Cinco" ~ "0203009170",
      eu_name == "Productores Pesqueros de Baja California" ~ "0203011499", #(or could be 0203001149)?
      eu_name == "Progreso" ~ "0203000021",
      eu_name == "Puerto San Carlos" ~ "0305000101",
      eu_name == "Punta Abreojos" ~ "0310000013",
      eu_name == "Punta Canoas" ~ "0203010715",
      eu_name == "Rafael Ortega Cruz" ~ "0203000351",
      eu_name == "Riberena Leyes de Reforma" ~ "0313000036",
      eu_name == "Riberenos de Puerto Catarina" ~ "0203126883",
      eu_name == "Roca San Martin" ~ "0203014063",
      eu_name == "Roeza" ~ "0203014550",
      eu_name == "Sea Urchin Pacific" ~ "0203012646",
      eu_name == "Todos Santos" ~ "0305000119",
      eu_name == "Union de Pescadores Buzos de la Costa Occidental de BC" ~ "0203005673"
    )
  ) %>% 
  st_transform(crs = 4326) %>% 
  filter(!(management == "Permit" & eu_rnpa == "0203000302")) %>% 
  group_by(eu_name, eu_rnpa, management) %>% 
  summarize(a = 1) %>% 
  ungroup() %>% 
  select(-a) %>% 
  mutate(fishery = "lobster")

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
st_write(obj = final,
         dsn = here("data", "concesiones", "processed", "nurs_lobster_permit_and_concessions_polygons.gpkg"),
         delete_dsn = T)
