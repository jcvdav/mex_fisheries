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
library(raster)
library(tidyverse)

# Load data --------------------------------------------------------------------
files <- list.files(
  path = here("data", "spatial_features", "clean"),
  pattern = "tif$")
rasters <- here("data", "spatial_features", "clean", files)%>%
  stack()
## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
features_df <- rasters %>%
  as.data.frame(xy = T) %>%
  mutate(
    distance_from_port_m = distance_to_port_raster * 1e3,
    distance_from_shore_m = distance_to_shore_raster * 1e3,
    all_na = (
      is.na(distance_from_port_m) +
        is.na(distance_from_shore_m) +
        is.na(depth_raster) +
        is.na(seas_raster)
    ) == 4
  ) %>%
  filter(!all_na) %>%
  select(
    lon_center = x,
    lat_center = y,
    sea = seas_raster,
    eez = eez_raster,
    contains("_m"),
    depth_m = depth_raster
  )
## EXPORT ######################################################################

# Export CSV -------------------------------------------------------------------
data.table::fwrite(
  x = features_df,
  file = here("data", "spatial_features", "clean", "spatial_features.csv")
)
