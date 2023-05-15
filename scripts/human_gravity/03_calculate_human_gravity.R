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
library(furrr)
library(sf)
library(tidyverse)

plan(multisession)

# Define data ------------------------------------------------------------------
base_grid <- raster(xmn = -124, xmx = -83,
                    ymn = 10, ymx = 35,
                    res = 0.05,
                    crs = 4326,
                    val = 1)

# Load data --------------------------------------------------------------------

us_pop <- st_read(dsn = here("data", "human_population", "processed", "usa_population.gpkg")) %>% 
  select(state, population)

mx_pop <- st_read(dsn = here("data", "human_population", "processed", "mex_population.gpkg")) %>% 
  # filter(state %in% c("Baja California", "Baja California Sur")) %>% 
  select(state, population)

pop <- rbind(us_pop, mx_pop) %>% 
  st_crop(base_grid)

coast <- ne_countries(country = c("Mexico", "United States of America", "Guatemala", "Belize"),
                      scale = "large",
                      returnclass = "sf") %>% 
  st_crop(st_bbox(pop)) %>%
  mutate(a = 1) %>% 
  group_by(a) %>% 
  summarize() %>% 
  ungroup() %>% 
  select(-a)

eez <-
  st_read(dsn = here("data", "spatial_features", "raw", "EEZ_land_union_v3_202003")) %>%
  janitor::clean_names() %>% 
  filter(iso_ter1 == "MEX") %>%
  fasterize::fasterize(raster = base_grid)

# kelp_pts <- st_read(here("../data_remotes", "data", "kelp", "processed", "area", "pixels_with_kelp.gpkg"))

# Define functions -------------------------------------------------------------
# Create function to call on each point. The function takes four arguments:
# - point: The point of interest
# - ciites: The shapefile of cities (you can filter it for pop size ahead of
# time, or do it within the function)
# - buffer: The buffer to keep around points, in meters (defaults to 500 Km)
# - max_pop: Thershold population size to filter for. It's more efficient to
# filter  outside ONCE, instead of filtering inside for EACH point
#
get_gravity <- function(point, buffer = 5e5, max_pop = NULL) {
  # browser()
  # Step 1 ---------------------------------------------------------------------
  # Create a buffer to filter out the data, this is
  # simply to avoid computing all the pairwise distances that are beyond the
  # buffer
  point_buffer <-
    sf::st_buffer(
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
    sf::st_filter(point_buffer)                                                     # Spatially filter
  
  if(nrow(influencers)== 0L) {
    gravity <- 0
  } else {
    # Step 4 ---------------------------------------------------------------------
    # Calculate distances
    distance <- sf::st_distance(x = point, y = influencers, by_element = T) %>%
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

# Prepare buffers --------------------------------------------------------------

# One for all cities within 50 km of the coast
coastal_cities_buffer <- coast %>%
  st_cast("MULTILINESTRING") %>%
  st_set_precision(1000) %>% 
  st_buffer(dist = 5e4) %>% 
  select(geometry)

# A buffer of 10 km around the coastline
coastline_buffer <- coast %>%
  st_cast("MULTILINESTRING") %>%
  st_set_precision(1000) %>% 
  st_buffer(dist = 1e4) %>% 
  select(geometry)

# Apply spatial filters --------------------------------------------------------

# Keep human settlements within 50 km of the coast
cities <- pop %>% 
  st_filter(coastal_cities_buffer)

# Keep only raster cells that are within 10 km of the coast, and in the ocean
pts_in_eez <- eez %>%
  mask(coast, inverse = T) %>% # filters out land pixels
  mask(coastline_buffer) # Filters out pixels furhter than 10 km away


# Prepare the points for which I want gravity ----------------------------------
 pts <- pts_in_eez %>% 
  as.data.frame(xy = T) %>%
  drop_na() %>% 
  st_as_sf(coords = c("x", "y"),
           crs = 4326)

# Calculate the gravity for each point -----------------------------------------
# using a 50 km radius
# You can also use the coordinates for the towns of relevance, not the coasline,
# to get a more precise value.
gravity <- pts %>%
  mutate(id = 1:nrow(.)) %>%
  group_by(id) %>%
  nest() %>%
  ungroup() %>% 
  mutate(gravity = future_map_dbl(data,
                                  get_gravity,
                                  .options = furrr_options(globals = "cities",
                                                           seed = 1))) %>%
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
          file = here("data", "human_population", "processed", "human_gravity_10km_buffer.csv"))


















