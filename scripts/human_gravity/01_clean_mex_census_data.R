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
library(sf)
library(tidyverse)

# Load data --------------------------------------------------------------------
# Load data
# This is just pointing to my downloads folder. You'll want to create an RStudio
# project and keep the data locally.
pop_data <- read_csv(
  file = here("data", "human_population", "raw", "AllMexicoLocalities2020.csv")
)

## PROCESSING ##################################################################

# A quick and dirty data cleanning... needs lots more work ---------------------
clean_pop <- pop_data %>%
  select(lon = LONGITUD, lat = LATITUD, pop = POBTOT,
         NOM_ENT, NOM_MUN, NOM_LOC) %>%                                         # Select only relevant columns
  distinct() %>%                                                                # Remove "duplicates" (not actual duplicates)
  drop_na(lat, lon) %>%                                                         # Remove data where coordinates are missing
  # Use regular expressions to extract the lat/long pieces and tranform into into decimal degrees
  mutate(
    deg = as.numeric(str_extract(string = lon, pattern = "[:digit:]+(?=°)")),
    min = as.numeric(str_extract(string = lon, pattern = "[:digit:]+(?=')")),
    seg = as.numeric(str_extract(string = lon, pattern = "[:digit:]+.[:digit:]+(?=\")")),
    lon = - 1 * (deg + (min / 60) + (seg / 3600))) %>%
  mutate(
    deg = as.numeric(str_extract(string = lat, pattern = "[:digit:]+(?=°)")),
    min = as.numeric(str_extract(string = lat, pattern = "[:digit:]+(?=')")),
    seg = as.numeric(str_extract(string = lat, pattern = "[:digit:]+.[:digit:]+(?=\")")),
    lat = deg + (min / 60) + (seg / 3600)) %>%
  select(lon, lat, state = NOM_ENT, municipality = NOM_MUN, locality = NOM_LOC, population = pop)                                                     # remove clutter

# Create spatial object
sf_pop <- st_as_sf(clean_pop,
                   coords = c("lon", "lat"),
                   dim = "XY",
                   crs = "EPSG:4326")

## EXPORT ######################################################################

# Save geopackage -------------------------------------------------------------
st_write(
  obj = sf_pop,
  dsn = here("data", "human_population", "processed", "mex_population.gpkg"),
  delete_dsn= T
)
