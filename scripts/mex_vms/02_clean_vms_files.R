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
library(janitor)
library(data.table)
library(furrr)
library(magrittr)
library(tidyverse)

source(here("scripts", "00_setup.R"))

# Define functions -------------------------------------------------------------
# Convert timestmaps to datetimes
to_datetime <- function(x) {
  date <- str_extract(x, "[:digit:]+/[:digit:]+/[:digit:]+")
  nas <- is.na(date)
  time <- str_extract(x, "[:digit:]+:[:digit:]+")
  date <- lubridate::dmy(date)
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
  
  fixed_colnames <- case_when(current_colnames %in% c("embarcaci_n", "nombre") ~ "name",
                              current_colnames %in% c("rnp") ~ "vessel_rnpa",
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
                                                      "fecha_recepcion_unitrac") ~ "datetime",
                              current_colnames %in% c("latitud") ~ "lat",
                              current_colnames %in% c("longitud") ~ "lon",
                              current_colnames %in% c("velocidad") ~ "speed",
                              current_colnames %in% c("curso",
                                                      "rumbo") ~ "course")
  
  colnames(data) <- fixed_colnames
  
  return(data)
}


# Cleaning function 
clean_vms <- function(data, year, month) {
  
  # Assign names to each path --------------------------------------------------
  names(data$path) <- data$src
  
  # Read in --------------------------------------------------------------------
  dt <- data %$%
    map(
      path,
      fread,
      select = 1:9,
      colClasses = "character",
      na.strings = c("NULL", "NA"),
      blank.lines.skip = TRUE
    ) %>% 
    map(fix_colnames) %>% 
    bind_rows(.id = "src")
  
  setkey(dt, vessel_rnpa)
  
  # Process the data -----------------------------------------------------------
  dt[, `:=` (
    datetime = to_datetime(datetime),
    lat = as.numeric(lat),
    lon = as.numeric(lon)
  )]
  dt[, vessel_rnpa := fix_rnpa(vessel_rnpa)]
  dt$year <- year
  dt$month <- as.numeric(month)
  
  dt <- dt %>% 
    select(src, name, vessel_rnpa, port, economic_unit, datetime, lat, lon, speed, course, year, month)
  
  # Export the file ------------------------------------------------------------
  fwrite(
    x = dt,
    file = here(
      "data",
      "mex_vms",
      "clean",
      paste0("MEX_VMS_", year, "_", month, ".csv")
    )
  )
}

## PROCESSING ##################################################################

# Identify files ---------------------------------------------------------------
paths <-
  list.files(
    path = here("data", "mex_vms", "raw"),
    recursive = T,
    pattern = "*\\.csv",
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
    year = as.numeric(str_extract(file, pattern = "[:digit:]{4}")),
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
  nest(data = c(path, src)) %$%
  future_pwalk(.l = list(data = data, year = year, month = month),
               .f = clean_vms)

plan(sequential)

## EXPORT ######################################################################
system(paste0("date >> ", here::here("data", "mex_vms", "clean", "clean.log")))
