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
library(rmapshaper)
library(fasterize)
library(raster)
library(sf)
library(tidyverse)

# Load data --------------------------------------------------------------------
seas_raw <- st_read(dsn = here("data", "spatial_features", "raw", "GOaS", "goas_v01.gpkg")) %>% 
  select(name) %>% 
  arrange(name) %>% 
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
seas_raster <- fasterize(
  sf = seas_raw,
  raster = reference_raster,
  field = "id",
  background = NA
)

seas_data_frame <- seas_raw %>% 
  st_drop_geometry()

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
write.csv(
  x = seas_data_frame,
  file = here(
    "data",
    "spatial_features",
    "clean",
    "seas_dictionary.csv"
  )
)

writeRaster(
  seas_raster,
  filename = here(
    "data",
    "spatial_features",
    "clean",
    "seas_raster.tif"
  ),
  overwrite = T
)

file.remove(here(
  "data",
  "spatial_features",
  "clean",
  "seas_raster.tif.aux.xml"
))
