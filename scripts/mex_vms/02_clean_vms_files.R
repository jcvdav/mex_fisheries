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
  data.table,
  furrr,
  rnaturalearth,
  sf,
  magrittr,
  tidyverse
)

source(here("scripts", "00_setup.R"))

# Define functions -------------------------------------------------------------
# Convert timestmaps to datetimes
to_datetime <- function(x) {
  # browser()
  # date <- str_extract(x, "[:digit:]+/[:digit:]+/[:digit:]+")
  date <- str_extract(x, "[:digit:]+[:punct:][:digit:]+[:punct:][:digit:]+")
  d1 <- max(str_count(str_extract(date, "[:digit:]+")), na.rm = T) # length of first item
  nas <- is.na(date)
  time <- str_extract(x, "[:digit:]+:[:digit:]+")
  if(d1 == 2){
    date <- lubridate::dmy(date)
  }
  if(d1 == 4){
    date <-  lubridate::ymd(date)
  }
  date <- str_replace_all(date, "/", "-")
  datetime <- paste0(date, " ", time, ":00")
  datetime[nas] <- NA
  return(datetime)
}

# Standardize column names
fix_colnames <- function(file){
  data <- file %>% 
    clean_names() %>% 
    select(sort(names(.)))
  
  current_colnames <- colnames(data)
  
  fixed_colnames <- case_when(current_colnames %in% c("embarcaci_n", "nombre", "nombre_embarcacion") ~ "name",
                              current_colnames %in% c("rnp", "rnpa") ~ "vessel_rnpa",
                              current_colnames %in% c("puerto_base",
                                                      "descripcion",
                                                      "descripcion_3") ~ "port",
                              current_colnames %in% c("permisionario_o_concesionario",
                                                      "pemisionario_o_concesionario",
                                                      "razon_social",
                                                      "raz_n_social",
                                                      "descripcion_2",
                                                      "descripcion_4") ~ "economic_unit",
                              current_colnames %in% c("fecha",
                                                      "fecha_recepcion_unitrac",
                                                      "ultima_transmision") ~ "datetime",
                              current_colnames %in% c("latitud") ~ "lat",
                              current_colnames %in% c("longitud") ~ "lon",
                              current_colnames %in% c("velocidad") ~ "speed",
                              current_colnames %in% c("curso",
                                                      "rumbo") ~ "course")
  
  colnames(data) <- fixed_colnames
  
  return(data)
}

# Clean land points
#From: https://github.com/CBMC-GCMP/dafishr/blob/master/R/clean_land_points.R
clean_land_points <- function(x, land) {
  sf::sf_use_s2(FALSE)
  
  x <- drop_na(x, lat, lon) %>% 
    sf::st_as_sf(coords = c("lon", "lat"),
                 crs = 4326,
                 remove = F)
  x <- sf::st_filter(x, land, .predicate = st_disjoint)
  x <- x |>
    sf::st_drop_geometry()
  return(x)
}

mex <- ne_countries(scale = "large",
                    country = "Mexico",
                    returnclass = "sf") 

land <- ne_countries(scale = "small",
                     continent = c("North America", "Central America", "South America"),
                     returnclass = "sf") %>% 
  filter(!iso_a3 %in% c("MEX", "GRL")) %>% 
  bind_rows(mex) %>% 
  st_union()

# Cleaning function 
clean_vms <- function(data, out_dir = here("data/mex_vms/clean")) {
  # browser()
  # Checks ---------------------------------------------------------------------
  # Check that directory exists
  if(!dir.exists(out_dir)) {
    print(paste("Directory", out_dir, "not found, creating one..."))
    dir.create(out_dir)
  }
  
  # Extract file name parts
  year <- unique(data$year)
  month <- unique(data$month)
  out_file <- here(out_dir, paste0("MEX_VMS_", year, "_", month, ".csv"))
  
  if(!file.exists(out_file)) {
    
    
    # Assign names to each path --------------------------------------------------
    names(data$path) <- data$src
    
    # Read in --------------------------------------------------------------------
    dt <- data %$%
      map(
        path,
        fread,
        # select = 1:11, ######### Number of columns to select. Usually 1-9, sometims 1-11
        colClasses = "character",
        na.strings = c("NULL", "NA", "N/A"),
        blank.lines.skip = TRUE
      ) %>% 
      map(fix_colnames) %>% 
      bind_rows(.id = "src")
    
    setkey(dt, vessel_rnpa)
    
    # Process the data -----------------------------------------------------------
    dt[, `:=` (
      datetime = to_datetime(datetime),
      lat = round(x = as.numeric(str_replace(lat, ",", "\\.")), digits = 5),
      lon = round(x = as.numeric(str_replace(lon, ",", "\\.")), digits = 5)
    )]
    dt[, vessel_rnpa := fix_rnpa(vessel_rnpa)]
    dt$year <- year
    dt$month <- as.numeric(month)
    
    
    dt <- dt %>%
      select(src, name, vessel_rnpa, port, economic_unit, datetime, lat, lon, speed, course, year, month) %>%
      clean_land_points(land = land)
    
    
    # Export the file ------------------------------------------------------------
    fwrite(
      x = dt,
      file = out_file
    )
  } else {print(paste("Skipping", basename(out_file), "because it already exists..."))}
}

## PROCESSING ##################################################################

# Identify files ---------------------------------------------------------------
paths <-
  list.files(
    path = here("data", "mex_vms", "raw"),
    recursive = T,
    pattern = "*\\.csv|*\\.CSV",
    full.names = T
  )

# Flag the ones that have messy dates ------------------------------------------
has_messy_datetimes <-
  c("21-31-AGO-2014.csv",
    "11-20-ENE-2018.csv",
    "16-31 OCT 2020.csv")

# Assamble file info -----------------------------------------------------------
metadata <- tibble(path = paths) %>% 
  mutate(
    file = basename(path),
    day_range = str_extract(file, pattern = "[:digit:]+-[:digit:]+"),
    month = str_extract(file, pattern = "[:alpha:]{3}"),
    year = as.integer(str_extract(dirname(path), pattern = "[:digit:]{4}")),
    month = case_when(
      month == "ENE" ~ "01",
      month == "FEB" ~ "02",
      month == "MAR" ~ "03",
      month == "ABR" ~ "04",
      month == "MAY" ~ "05",
      month == "JUN" ~ "06",
      month == "JUL" ~ "07",
      month == "AGO" ~ "08",
      month == "SEP" ~ "09",
      month == "OCT" ~ "10",
      month == "NOV" ~ "11",
      month == "DIC" ~ "12"
    )
  ) %>%
  mutate(
    messy_dates = file %in% has_messy_datetimes,
    year_month = paste(year, month, sep = "_"),
    src = str_remove(file, ".csv"),
    src = str_replace_all(src, " ", "-"),
    src = str_replace_all(src, "--", "-")
  )

# PROCESSING ###################################################################
# Define a cluster -------------------------------------------------------------
plan(multisession, workers = parallel::detectCores() - 2)

# Call cleaning function -------------------------------------------------------
metadata %>%
  select(year, month, path, src) %>%
  group_split(year, month) %>% 
  future_walk(.f = clean_vms)

plan(sequential)

## EXPORT ######################################################################
system(paste0("date >> ", here::here("data", "mex_vms", "clean", "clean.log")))
