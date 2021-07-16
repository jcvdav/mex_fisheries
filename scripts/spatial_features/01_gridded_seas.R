# Gridded oceans

library(sf)
library(rmapshaper)
library(raster)
library(fasterize)
library(tidyverse)

seas_raw <- st_read(dsn = file.path(data_path, "World_Seas_IHO_V3"), layer = "World_Seas_IHO_V3")

seas <- seas_raw %>% 
  filter(NAME %in% c("Gulf of Mexico", "Gulf of California", "Caribbean Sea", "North Pacific Ocean", "North Atlantic Ocean")) %>% 
  mutate(ID = as.numeric(ID))

reference_raster <- raster(xmn = -180, xmx = 0, ymn = 0, ymx = 60, resolution = 0.1)

seas_raster <- fasterize(sf = seas,
                         raster = reference_raster,
                         field = "MRGID",
                         background = NA)

seas_data_frame <- seas_raster %>% 
  as.data.frame(xy = T) %>% 
  magrittr::set_colnames(value = c("lon", "lat", "MRGID")) %>% 
  left_join(st_drop_geometry(seas), by = "MRGID") %>% 
  drop_na(MRGID) %>% 
  select(lon, lat, mrgid = MRGID, name = NAME)





write.csv(x = seas_data_frame,
          file = file.path(project_path, "processed_data", "SPATIAL_FEATURES", "seas_dataframe.csv"))

writeRaster(seas_raster,
            filename = file.path(project_path, "processed_data", "SPATIAL_FEATURES", "seas_raster.tif"))



















