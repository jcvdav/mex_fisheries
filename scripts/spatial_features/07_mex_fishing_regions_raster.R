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
regions <-
  st_read(dsn = here("data", "spatial_features", "clean", "mexico_fishing_regions.gpkg")) 

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
regions_raster <- fasterize(
  sf = regions,
  raster = reference_raster,
  field = "region",
  background = NA
)

regions_data_frame <- regions %>%
  st_drop_geometry()

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
write.csv(
  x = regions_data_frame,
  file = here("data",
              "spatial_features",
              "clean",
              "mexico_fishing_regions_dictionary.csv")
)

writeRaster(
  regions_raster,
  filename = here("data",
                  "spatial_features",
                  "clean",
                  "mexico_fishing_regions_raster.tif"),
  overwrite = T
)


file.remove(here("data",
                 "spatial_features",
                 "clean",
                 "mexico_fishing_regions_raster.tif.aux.xml"))
