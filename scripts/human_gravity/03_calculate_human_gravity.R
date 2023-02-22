################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Calculat ethe "population gravity" (or "commercialization gravity") for any
# given point, using Mexico's data on location and population sizes of human
# settlements.
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
library(here)
library(raster)
library(rnaturalearth)
library(sf)
library(tidyverse)

# Load data --------------------------------------------------------------------

us_pop <- st_read(dsn = here("data", "human_population", "processed", "usa_population.gpkg")) %>% 
  select(state, population)

mx_pop <- st_read(dsn = here("data", "human_population", "processed", "mex_population.gpkg")) %>% 
  filter(state %in% c("Baja California", "Baja California Sur")) %>% 
  select(state, population)


pop <- rbind(us_pop, mx_pop)

coast <- ne_countries(country = c("Mexico", "United States of America"),
                      scale = "large",
                      returnclass = "sf") %>% 
  st_crop(st_bbox(pop)) %>% 
  mutate(a = 1) %>% 
  group_by(a) %>% 
  summarize() %>% 
  ungroup() %>% 
  select(-a)

# base_grid <- raster(here("../data_remotes","data", "standard_grid.tif"))

kelp_pts <- st_read(here("../data_remotes", "data", "kelp", "processed", "area", "pixels_with_kelp.gpkg"))

# Define functions -------------------------------------------------------------
# Create function to call on each point. The function takes four arguments:
# - point: The point of interest
# - ciites: The shapefile of cities (you can filter it for pop size ahead of
# time, or do it within the function)
# - buffer: The buffer to keep around points, in meters (defaults to 500 Km)
# - max_pop: Thershold population size to filter for. It's more efficient to
# filter  outside ONCE, instead of filtering inside for EACH point
#
get_gravity <- function(point, cities, buffer = 5e5, max_pop = NULL) {
  # browser()
  # Step 1 ---------------------------------------------------------------------
  # Create a buffer to filter out the data, this is
  # simply to avoid computing all the pairwise distances that are beyond the
  # buffer
  point_buffer <-
    st_buffer(
      x = point,
      dist = buffer
    )
  
  # Step 2 ---------------------------------------------------------------------
  # If a max_pop was suggested, filter the data, otherwise use the entire data
  if(!is.null(max_pop)){
    cities <- cities %>%
      dplyr::filter(population >= max_pop)
  }
  
  # Step 3 ---------------------------------------------------------------------
  # Define which are the influencers
  influencers <-
    cities %>%
    st_filter(point_buffer)                                                     # Spatially filter
  
  if(nrow(influencers)== 0L) {
    gravity <- 0
  } else {
    # Step 4 ---------------------------------------------------------------------
    # Calculate distances
    distance <- st_distance(x = point, y = influencers, by_element = T) %>%
      units::drop_units() / 1e3
    
    self <- distance == 0                                                         # In case the poit of interest happens to be a city (distance to itself is 0, and you cant' divide by 0)
    
    # Step 5 ---------------------------------------------------------------------
    # Calculate population gravity for each city in the buffer
    gravity <- sum((influencers$population[!self] / (distance[!self] ^ 2)), na.rm = T)
  }
  
  # Return results
  return(gravity)
}


## PROCESSING ##################################################################

# Prepare buffers

# One for all cities within 50 km of the coast
coastal_cities_buffer <- coast %>%
  st_cast("MULTILINESTRING") %>%
  # st_cast("LINESTRING") %>%
  # st_transform(crs = "ESRI:54009") %>%
  st_buffer(dist = 5e4) %>% 
  select(geometry)

# Keep only human settlements within 50 km of the coast
pop_within_coast <- pop %>% 
  # st_transform(crs = "ESRI:54009") %>% 
  st_filter(coastal_cities_buffer)

# Prepare the points for which I want gravity ----------------------------------
# pts <- base_grid %>% 
#   mask(coast, inverse = T) %>% 
#   mask(ocean_buffer) %>% 
#   crop(extent(c(xmin = -120,
#                 xmax = -114,
#                 ymin = 27,
#                 ymax = 32.5))) %>% 
#   as.data.frame(xy = T) %>% 
#   st_as_sf(coords = c("x", "y"), crs = 4326)
# 


# Un-comment to visualize layers that go into the calculation
# ggplot() +
#   geom_sf(data = coast, fill = "black") +
#   geom_sf(data = coastal_cities_buffer, color = "red", fill = "transparent") +
#   geom_sf(data = pop_within_coast, color = "red", pch = ".") +
#   geom_sf(data = kelp_pts, color = "green", pch = ".") +
#   theme_void()

# Calculate the gravity for each point -----------------------------------------
# using a 50 km radius
# You can also use the coordinates for the towns of relevance, not the coasline,
# to get a more precise value.
gravity <- kelp_pts %>%
  select(-gravity) %>%
  mutate(id = 1:nrow(.)) %>%
  group_by(id) %>%
  nest() %>%
  ungroup() %>% 
  mutate(gravity = map_dbl(data,
                           get_gravity,
                           cities = pop_within_coast ,
                           buffer = 5e4)) %>%
  unnest(data) %>%
  ungroup() %>%
  st_as_sf()


gravity_table <- gravity %>% 
  cbind(st_coordinates(.)) %>% 
  st_drop_geometry() %>% 
  select(lon = X, lat = Y, gravity)

## EXPORT ######################################################################

# Export CSV
write_csv(x = gravity_table,
          file = here("data", "human_population", "processed", "human_gravity_for_kelp_patches.csv"))

# There are a few issues with the data that come out of this process:
#
# - We might want to add Oregon


















