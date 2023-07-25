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
  sf,
  tidyverse
)

# Load data --------------------------------------------------------------------

nur <- st_read(here("data", "concesiones", "processed", "nurs_lobster_permit_and_concessions_polygons.gpkg"))

ere <- st_read(here("data", "concesiones", "processed", "eres_lobster_permit_and_concessions_polygons.gpkg"))

## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------

lobster <- bind_rows(nur, ere)

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------
st_write(obj = lobster,
         dsn = here("data", "concesiones", "processed", "lobster_permit_and_concessions_polygons.gpkg"),
         delete_dsn = T)
