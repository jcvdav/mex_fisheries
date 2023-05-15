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
  raster,
  bigrquery,
  DBI,
  magrittr,
  tidyverse
)

# Authenticate into BigQuery ---------------------------------------------------
bq_auth("juancarlos@ucsb.edu")

connection <- dbConnect(drv = bigquery(),
                        project = "emlab-gcp",
                        dataset = "mex_fisheries",
                        billing = "emlab-gcp",
                        use_legacy_sql = FALSE,
                        allowLargeResults = TRUE)

mex_vms <- tbl(src = connection,
               from = "mex_vms_processed_v_20230419")

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
# Define target resolution
res <- 0.01

# Define query
grided_measures <- mex_vms %>% 
  filter(speed > 0,
         between(lon, -140, -75),
         between(lat, 0, 35)) %>% 
  mutate(lon = (round(lon / res) * res) + (res / 2),
         lat = (round(lat / res) * res) + (res / 2)) %>% 
  group_by(year, lon, lat) %>% 
  summarize(hours = sum(hours, na.rm = T),
            vessels = n_distinct(vessel_rnpa)) %>% 
  ungroup() 

# Collect data
local_grided_measures <- collect(grided_measures)

# Buidl rasters ----------------------------------------------------------------
# Define function
wrap_raster <- function(year, data, column){
  name <- paste0("msep_", column, "_", year, ".tif")
  
  r <- rasterFromXYZ(xyz = data[, c("lon", "lat", column)],
                     res = res,
                     crs = 4326) %>% 
    extend(e)
  
  writeRaster(x = r,
              filename = here("data", "mex_fishing_effort", "processed", column, name),
              overwrite = TRUE)
}

# Define globals
e <- extent(c(-140, -75, 0, 35))

# Nest data
nested <- local_grided_measures %>% 
  group_by(year) %>% 
  nest()

# Export hours
nested %$% 
  walk2(year, data, wrap_raster, column = "hours")

# Export n_vessels
nested %$% 
  walk2(year, data, wrap_raster, column = "vessels")

file.remove(list.files(path = here("data", "mex_fishing_effort"), pattern = "aux", recursive = T, full.names = T))

# END OF SCRIPT