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
library(fasterize)
library(raster)
library(sf)
library(tidyverse)

# Load data --------------------------------------------------------------------
eez_raw <-
  st_read(dsn = here("data", "spatial_features", "raw", "EEZ_land_union_v3_202003")) %>%
  janitor::clean_names()

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
eez_raster <- fasterize(
  sf = eez_raw,
  raster = reference_raster,
  field = "mrgid_eez",
  background = NA
)

eez_data_frame <- eez_raw %>%
  st_drop_geometry()

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
write.csv(
  x = eez_data_frame,
  file = here("data",
              "spatial_features",
              "clean",
              "eez_dictionary.csv")
)

writeRaster(
  eez_raster,
  filename = here("data",
                  "spatial_features",
                  "clean",
                  "eez_raster.tif"),
  overwrite = T
)


file.remove(here("data",
                 "spatial_features",
                 "clean",
                 "eez_raster.tif.aux.xml"))
