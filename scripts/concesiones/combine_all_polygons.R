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
lobster <-
  sf::st_read(dsn = here(
    "data",
    "concesiones",
    "processed",
    "lobster_permit_and_concessions_polygons.gpkg"
  ))

urchin <-
  sf::st_read(dsn = here(
    "data",
    "concesiones",
    "processed",
    "urchin_permit_and_concessions_polygons.gpkg"
  ))

cucumber <-
  sf::st_read(dsn = here(
    "data",
    "concesiones",
    "processed",
    "sea_cucumber_permit_and_concessions_polygons.gpkg"
  ))

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
polygons <- bind_rows(lobster, urchin, cucumber) %>% 
  select(eu_rnpa, fishery)

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
st_write(obj = polygons,
         dsn = here("data", "concesiones", "processed", "all_spp_permit_and_concessions_polygons.gpkg"),
         delete_dsn = T)
