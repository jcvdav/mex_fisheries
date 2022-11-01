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

others <-
  st_read(dsn = here(
    "data",
    "concesiones",
    "processed",
    "non_fedecoop_polygons.gpkg"
  ))

fedecoop <-
  st_read(here("data", "concesiones", "raw", "fedecoop_polygons.gpkg")) %>%
  select(coop_name = coop) %>%
  mutate(name = coop_name) %>%
  st_transform(crs = "EPSG:4326")

coop_eurnpa <- tibble(
  eu_rnpa = c(
    "0301000089",
    "0301000113",
    "0313000028",
    "0301000097",
    "0301000105",
    "0313000036",
    "0203000021",
    "0310000013",
    "0203000278",
    "0203000302",
    "0203008305",
    "0203008990",
    "0203008198",
    "0203126602",
    "0203009261",
    "0203010715",
    "0203005673",
    "0203002829",
    "0203004726",
    "0203126974",
    "0203014063",
    "0203006168",
    "0203000351",
    "0203007901"
  ),
  coop = c(
    "Buzos y Pescadores",
    "Bahia de Tortugas",
    "California de San Ignacio",
    "Emancipacion",
    "La Purisima",
    "Leyes de Reforma",
    "Progreso",
    "Punta Abreojos",
    "Isla Cedros",
    "Ensenada",
    "Litoral de Baja California",
    "Manchuria",
    "Morro de Rosarito",
    "Jauregui Hernandez",
    "Pescadores Ribereños",
    "Punta Canoas",
    "Buzos de la Costa Occidental",
    "Abuloneros y Langosteros",
    "Regasa",
    "Isla San Geronimo",
    "Roca San Martin",
    "Patrimonio en el mar",
    "Rafael Ortega Cruz",
    "Pescadores Ribereños de BC"
  )
)

concession_polygons <- rbind(others, fedecoop) %>%
  rename(pol_name = name) %>%
  left_join(coop_eurnpa, by = c("coop_name" = "coop")) %>% 
  mutate(id = 1:nrow(.))

## EXPORT ######################################################################

# Export geopackage  -----------------------------------------------------------
st_write(
  obj = concession_polygons,
  dsn = here(
    "data",
    "concesiones",
    "processed",
    "lobster_turf_polygons.gpkg"
  ),
  delete_dsn = T
)
