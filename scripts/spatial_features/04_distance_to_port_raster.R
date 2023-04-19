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
library(terra)
library(tidyverse)

# Load data --------------------------------------------------------------------
gmed_raster <-
  rast(here(
    "data",
    "spatial_features",
    "raw",
    "port_distance",
    "port_distance.asc"
  ))

# Create a reference raster ----------------------------------------------------
reference_raster <-
  rast(
    xmin = -180,
    xmax = 180,
    ymin = -90,
    ymax = 90,
    resolution = 0.05
  )

## PROCESSING ##################################################################
# Downscale and export ---------------------------------------------------------
resample(
  x = gmed_raster,
  y = reference_raster,
  method = "bilinear",
  filename = here("data",
                  "spatial_features",
                  "clean",
                  "distance_to_port_raster.tif"),
  overwrite = T
)