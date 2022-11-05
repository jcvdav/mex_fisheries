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

# Cleaning funciton 
clean_vms <- function(data, year, month) {
  
  # Assign names to each path --------------------------------------------------
  names(data$path) <- data$src
  
  # Read in --------------------------------------------------------------------
  dt <- data %$%
    map_dfr(
      path,
      fread,
      select = 1:9,
      colClasses = "character",
      col.names = c(
        "name",
        "vessel_rnpa",
        "port",
        "economic_unit",
        "datetime",
        "lat",
        "lon",
        "speed",
        "course"
      ),
      na.strings = c("NULL", "NA"),
      blank.lines.skip = TRUE,
      .id = "src"
    )
  
  
  
  # Process the data -----------------------------------------------------------
  dt[, `:=` (
    datetime = to_datetime(datetime),
    lat = as.numeric(lat),
    lon = as.numeric(lon)
  )]
  dt[, vessel_rnpa := fix_rnpa(vessel_rnpa)]
  dt$year <- year
  dt$month <- as.numeric(month)
  
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
    month = str_extract(file, pattern = "[:alpha:]+"),
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
  pwalk(.l = list(data = data, year = year, month = month), clean_vms)

## EXPORT ######################################################################
system(paste0("date >> ", here::here("data", "mex_vms", "clean", "clean.log")))

# X ----------------------------------------------------------------------------

## Set up
# Load packages

# clean_vms2 <- function(data, year, month) {
#   browser()
#   names(data$path) <- data$src
#   dt <- data %$%
#     map_dfr(path, fread,
#             select = 1:9,
#             colClasses = "character",
#             col.names = c("name", "vessel_rnpa", "port", "economic_unit", "datetime", "lat", "lon", "speed", "course"),
#             na.strings = c("NULL", "NA"),
#             blank.lines.skip = TRUE,
#             .id = "src")
# #
# #
#   dt[, `:=` (datetime = to_datetime(datetime), lat = as.numeric(lat), lon = as.numeric(lon))]
#   dt[, vessel_rnpa := fix_rnpa(vessel_rnpa)]
#   dt$year <- year
#   dt$month <- as.numeric(month)
# #
# #
# #   # vessel_name_dictionary <- tibble(name = unique(dt$name)) %>%
# #   # mutate(vessel_name_norm = map_chr(name, normalize_shipname)) %>%
# #   # as.data.table()
# #
# #   # setkey(vessel_name_dictionary, "name")
# #   # setkey(dt, "name")
# #
# #   # dt <- merge(dt, vessel_name_dictionary, by = "name")
# #   # dt[name = NULL]
# #
# #   # return(dt)
# #
# #   # fwrite(x = dt,
# #          # file = file.path(project_path, "processed_data", "MEX_VMS", paste0("MEX_VMS_", year, "_", month, ".csv")))
# }