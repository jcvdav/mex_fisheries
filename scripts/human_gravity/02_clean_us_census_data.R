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
# US pop data from: https://data.census.gov/cedsci/table?q=acs&g=0100000US%241400000&y=2020&tid=ACSST5Y2020.S0101
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
library(here)
library(sf)
library(tidyverse)

# Load data --------------------------------------------------------------------
us_pop_data <- read_csv(file = "data/human_population/raw/ACSST5Y2020.S0101_2022-10-26T172451/ACSST5Y2020.S0101-Data.csv",
              skip = 2,
              col_select = 1:3,
              col_names = c("geography", "name", "population")) %>% 
  filter(str_detect(name, "California|Oregon"))

tracts <- tigris::tracts(cb = T)

## PROCESSING ##################################################################

# Select columns and filter ----------------------------------------------------
clean_us_pop <- 
  tracts %>% 
  filter(STATE_NAME %in% c("California", "Oregon")) %>% 
  st_centroid() %>% 
  st_transform(crs = "EPSG:4326") %>% 
  left_join(us_pop_data, by = c("AFFGEOID" = "geography")) %>% 
  select(state = STATE_NAME,  tract = NAMELSAD, population)

## EXPORT ######################################################################

# Save geopackage -------------------------------------------------------------
st_write(
  obj = clean_us_pop,
  dsn = here("data", "human_population", "processed", "usa_population.gpkg"),
  delete_dsn= T
)
