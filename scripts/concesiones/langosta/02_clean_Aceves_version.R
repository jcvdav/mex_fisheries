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
  janitor,
  sf,
  tidyverse
)

# UDFs -------------------------------------------------------------------------
my_read <- function(file){
  name <- str_remove(basename(file), ".shp")
  
  out <- st_read(file, quiet = T) %>% 
    mutate(source = name) %>% 
    select(source, everything())
  
  return(out)
}

# Load data --------------------------------------------------------------------
# Find all files
files <- list.files(here("data", "concesiones", "raw", "aceves_baja_turfs"),
                    pattern = "shp",
                    full.names = T)

# Read them all in, and combine
raw_shp <- files %>% 
  map_dfr(my_read) %>% 
  st_as_sf(geometry = "geometry") %>% 
  st_zm()

## PROCESSING ##################################################################

# Kep polygons and add missing data --------------------------------------------
missing_polygons <- raw_shp %>% 
  st_transform(crs = 4326) %>% 
  select(source) %>% 
  filter(source %in% c("BCS11", "BCS17")) %>% 
  mutate(eu_name = case_when(source == "BCS11" ~ "Pescadores de La Poza",
                             source == "BCS17" ~ "Puerto Chale"),
         eu_rnpa = case_when(source == "BCS11" ~ "0305000051",
                             source == "BCS17" ~ "0305000036"),
         management = "Concession",
         fishery = "lobster") %>% 
  select(-source)

## EXPORT ######################################################################

# X ----------------------------------------------------------------------------

st_write(obj = missing_polygons,
         dsn = here("data", "concesiones", "processed", "eres_lobster_permit_and_concessions_polygons.gpkg"),
         delete_dsn = T)