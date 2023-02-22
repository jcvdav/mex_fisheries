################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Create a raster layer of distance to coast
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
library(here)
library(raster)
library(tidyverse)

# Load data --------------------------------------------------------------------
gmed_raster <-
  raster(here(
    "data",
    "spatial_features",
    "raw",
    "land_distance",
    "gb_land_distance.asc"
  ))

# Create a reference raster ----------------------------------------------------
reference_raster <-
  raster(
    xmn = -180,
    xmx = 180,
    ymn = -90,
    ymx = 90,
    resolution = 0.05
  )

## PROCESSING ##################################################################
# Downscale and export ---------------------------------------------------------
resample(
  gmed_raster,
  reference_raster,
  method = "bilinear",
  filename = here("data",
                  "spatial_features",
                  "clean",
                  "distance_to_shore_raster.tif"),
  overwrite = T
)

file.remove(here(
  "data",
  "spatial_features",
  "clean",
  "distance_to_shore_raster.tif.aux.xml"
))
