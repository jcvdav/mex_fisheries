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


lob_pol <-
  map_dfr(
    st_layers(here("data", "concesiones", "raw", "lobster_concessions.gpkg"))$name,
    st_read,
    dsn = here("data", "concesiones", "raw", "lobster_concessions.gpkg")
  )

lob_pts <-
  map_dfr(
    st_layers(here("data", "concesiones", "raw", "lobster_concessions_pts.gpkg"))$name,
    st_read,
    dsn = here("data", "concesiones", "raw", "lobster_concessions_pts.gpkg")
  )

## PROCESSING ##################################################################

# Select polygons --------------------------------------------------------------
pols <- lob_pol %>%
  filter((st_geometry_type(.) %in% c("POLYGON", "MULTIPOLYGON"))) %>%
  st_zm() %>%
  select(pol_name = Name) %>%
  filter(!str_detect(pol_name, "PESCADORES NACIONALES")) %>%      # Drop Cedros because we already have it
  mutate(id = 1:nrow(.))

# Select points ----------------------------------------------------------------

points_poly <- lob_pol %>% filter(!(st_geometry_type(.) %in% c("POLYGON", "MULTIPOLYGON"))) %>%
  st_zm() %>% 
  group_by(Name) %>%
  summarize(a = 1) %>%
  filter(!str_detect(Name, "P[:digit:]")) %>% # Remove un-informative points that are just verices of existing polygons, and have no coop name
  select(pt_name = Name)

points_points <- lob_pts %>%
  filter(!(st_geometry_type(.) %in% c("POLYGON", "MULTIPOLYGON"))) %>%
  st_zm() %>%
  group_by(Name) %>%
  summarize(a = 1) %>%
  filter(!str_detect(Name, "P[:digit:]")) %>% # Remove un-informative points that are just verices of existing polygons, and have no coop name
  select(pt_name = Name)

points <- rbind(points_points,
                points_poly) %>% 
  filter(!str_detect(pt_name, "Campo|CAMPO|Var|ALMEJA|Puerto San Carlos"))


# Assign names to the polygons, based on the points ----------------------------
named_pol <- st_join(pols, points) %>%
  mutate(
    pol_name = case_when(
      # id == 4 ~ "Ensenada",
      # id == 6 ~ "Puerto Canoas - Punta Blanca",
      # id == 7 ~ "Rosarito",
      # id == 9 ~ "Ensenada - Vicente Guerrero",
      # id == 11 ~ "Sur El Rosario",
      # id == 12 ~ "Isla San Martín",
      # id == 14 ~ "San Quintín",
      # id == 15 ~ "Punta Blanca - Miller's",
      # id == 16 ~ "Guerrero Negro",
      between(id, 17, 20) ~ "Abuloneros y Langosteros",
      T ~ pol_name
    ),
    name = ifelse(
      pol_name %in% c("POLIGONO 1", "Polígono sin título"),
      pt_name,
      pol_name
    )
  ) %>%
  select(pol_name, pt_name, name)

remaining <- named_pol %>%
  select(name) %>%
  mutate(
    coop_name = case_when(
      name == "Abuloneros y Langosteros" ~ "Abuloneros y Langosteros",
      name == "ASOCIACION PESQUERA REGASA No. 2" ~ "Regasa",
      name == "GRUPO DE PESCADORES RIBEREÑOS" ~ "Pescadores Ribereños",
      name == "GRUPO JAUREGUI HERNANDEZ" ~ "Jauregui Hernandez",
      name == "ISLA SAN GERONIMO" ~ "Isla San Geronimo",
      name == "PESCADORES Y BUZOS RIBEREÑOS DE MANCHURIA" ~ "Manchuria",
      name == "ROCA SAN MARTIN, S.P.R. DE R.L." ~ "Roca San Martin",
      name == "S.P.R. PUNTA CANOAS" ~ "Punta Canoas",
      name == "SCPP ACUICOLA CON PATRIMONIO EN EL MAR" ~ "Patrimonio en el mar",
      name == "UPP AUT PESC MORRO ROSARITO S. DE R.L. DE C.V." ~ "Morro de Rosarito",
      name == "SCPP ENSENADA - ZONA I" ~ "Ensenada",
      name == "SCPP ENSENADA - ZONA II" ~ "Ensenada",
      name == "SCPP ENSENADA - ZONA III" ~ "Ensenada",
      name == "SCPP RAFAEL ORTEGA CRUZ" ~ "Rafael Ortega Cruz",
      name == "SPR LITORAL DE BAJA CALIFORNIA" ~ "Litoral de Baja California",
      name == "UNION DE PB DE LA COSTA OCC DE BC" ~ "Buzos de la Costa Occidental",
      name == "UPP PESCADORES RIBEREÑOS DE BC" ~ "Pescadores Ribereños de BC",
    ),
    name = ifelse(is.na(coop_name), name, coop_name)
  ) %>%
  group_by(coop_name, name) %>%
  summarize(a = 1) %>%
  ungroup() %>%
  select(-a)
## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
st_write(
  obj = remaining,
  dsn = here(
    "data",
    "concesiones",
    "processed",
    "non_fedecoop_polygons.gpkg"
  ),
  delete_dsn = T
)
