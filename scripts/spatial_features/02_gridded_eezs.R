# Gridded oceans

library(sf)
library(rmapshaper)
library(raster)
library(fasterize)
library(tidyverse)

eezs_raw <- st_read(dsn = file.path(data_path, "marine-regions-eez-v11", "World_EEZ_V11_20191118_gpkg", "eez_v11.gpkg"))

eez <- eezs_raw %>% 
  filter(ISO_TER1 == "MEX")

reference_raster <- raster(xmn = -180, xmx = 0, ymn = 0, ymx = 60, resolution = 0.1)

eez_raster <- fasterize(sf = eez,
                        raster = reference_raster,
                        field = "MRGID",
                        background = NA)

eez_data_frame <- eez_raster %>% 
  as.data.frame(xy = T) %>% 
  magrittr::set_colnames(value = c("lon", "lat", "MRGID")) %>% 
  left_join(st_drop_geometry(eez), by = "MRGID") %>% 
  drop_na(MRGID) %>% 
  select(lon, lat, mrgid = MRGID, iso3 = ISO_TER1)

write.csv(x = seas_data_frame,
          file = file.path(project_path, "processed_data", "SPATIAL_FEATURES", "seas_dataframe.csv"))

writeRaster(seas_raster,
            filename = file.path(project_path, "processed_data", "SPATIAL_FEATURES", "seas_raster.tif"))



















