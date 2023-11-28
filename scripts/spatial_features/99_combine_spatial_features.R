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
library(terra)
library(tidyverse)

# Load data --------------------------------------------------------------------
files <- list.files(
  path = here("data", "spatial_features", "clean"),
  pattern = "tif$",
  full.names = T)
rasters <- rast(files) %>% 
  focal(w = matrix(1, nrow = 5, ncol = 5),
        na.rm = T,
        fun = "min",
        na.policy = "only")
## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
features_df <- rasters %>%
  as.data.frame(xy = T) %>%
  select(
    lon_center = x,
    lat_center = y,
    sea = seas_raster,
    eez = eez_raster,
    distance_from_port_m = port_distance,
    distance_from_shore_m = gb_land_distance,
    depth_m = gb_depth,
  ) %>% 
  mutate(
    lon_center = round(lon_center, 4),
    lat_center = round(lat_center, 4),
    distance_from_port_m = distance_from_port_m * 1e5,
    distance_from_shore_m = distance_from_shore_m * 1e5,
    all_na = (
      is.na(distance_from_port_m) +
        is.na(distance_from_shore_m) +
        is.na(depth_m) +
        is.na(sea)
    ) == 4
  ) %>%
  filter(!all_na) %>%
  select(
    lon_center,
    lat_center,
    sea,
    eez,
    distance_from_shore_m,
    distance_from_port_m,
    depth_m
  ) %>% 
  replace_na(replace = list(
    seas_raster = 0,
    eez = 0,
    distance_from_port_m = 0,
    distance_from_shore_m = 0,
    depth_m = 0)
    )
## EXPORT ######################################################################

# Export CSV -------------------------------------------------------------------
data.table::fwrite(
  x = features_df,
  file = here("data", "spatial_features", "clean", "spatial_features.csv")
)
