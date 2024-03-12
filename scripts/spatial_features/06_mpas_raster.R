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
  rmapshaper,
  fasterize,
  raster,
  sf,
  tidyverse)


# Load data --------------------------------------------------------------------
mpas_raw <- st_read(here("data", "spatial_features", "clean", "mexico_mpas.gpkg")) %>% 
  dplyr::select(SITE_ID) %>% 
  arrange(SITE_ID) %>% 
  mutate(id = 1:nrow(.))

reference_raster <-
  raster(
    xmn = -180,
    xmx = 180,
    ymn = -90,
    ymx = 90,
    resolution = 0.05
  )

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
mpas_raster <- fasterize(
  sf = mpas_raw,
  raster = reference_raster,
  field = "id",
  background = NA
)

mpas_data_frame <- mpas_raw %>% 
  st_drop_geometry()

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
write.csv(
  x = mpas_data_frame,
  file = here(
    "data",
    "spatial_features",
    "clean",
    "mpas_dictionary.csv"
  )
)

writeRaster(
  mpas_raster,
  filename = here(
    "data",
    "spatial_features",
    "clean",
    "mpas_raster.tif"
  ),
  overwrite = T
)
