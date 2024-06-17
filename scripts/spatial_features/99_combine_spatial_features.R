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
  terra,
  tidyverse
)

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
  filter(between(y, -60, 60)) %>% 
  select(
    # Can not be NA
    lon_center = x,
    lat_center = y,
    sea = seas_raster,
    distance_from_port_m = port_distance,
    distance_from_shore_m = gb_land_distance,
    depth_m = gb_depth,
    # Can be NA
    eez = eez_raster,
    mpa = mpas_raster,
    fishing_region = mexico_fishing_regions_raster,
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
    mpa,
    fishing_region,
    distance_from_shore_m,
    distance_from_port_m,
    depth_m
  ) %>% 
  replace_na(replace = list(
    seas_raster = 0,
    eez = 0,
    mpa = 0,
    fishing_region = 0,
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
