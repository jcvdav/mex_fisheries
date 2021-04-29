######################################################
# Clean VMS data #
######################################################
# 
# Clean VMS data
#
######################################################

## Set up
# Load packages
library(data.table)
library(furrr)
library(magrittr)
library(tidyverse)

# Functions
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

fix_rnpa <- function(rnpa){
  lengths <- str_length(rnpa)
  missing <- pmax(8 - lengths, 0)
  zeroes <- map_chr(missing, ~paste(numeric(length = .x), collapse = ""))
  out <- paste0(zeroes, rnpa)
  return(out)
}

clean_vms <- function(data, year, month) {
  dt <- data %>% 
    pull(path) %>% 
    map_dfr(fread,
            select = 1:9,
            col.names = c("name", "rnpa", "port", "economic_unit", "datetime", "lat", "lon", "speed", "course"),
            na.strings = c("NULL", "NA"),
            blank.lines.skip = TRUE)
  
  dt[, `:=` (datetime = to_datetime(datetime), lat = as.numeric(lat), lon = as.numeric(lon))]
  dt[, rnpa := fix_rnpa(rnpa)]
  dt$year <- year
  dt$month <- as.numeric(month)
  
  fwrite(x = dt,
         file = file.path(project_path, "processed_data", paste0("MXN_VMS_", year, "_", month, ".csv")))
}


paths <- list.files(path = file.path(project_path, "raw_data", "VMS"),
                    recursive = T,
                    pattern = "*.csv",
                    full.names = T)

messy_dates <- c("21-31-AGO-2014.csv", "11-20-ENE-2018.csv", "16-31 OCT 2020.csv")

metadata <- tibble(path = paths) %>% 
  mutate(file = basename(path),
         day_range = str_extract(file, pattern = "[:digit:]+-[:digit:]+"),
         month = str_extract(file, pattern = "[:alpha:]+"),
         year = as.numeric(str_extract(file, pattern = "[:digit:]{4}")),
         month = case_when(month == "ENE" ~ "01",
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
                           month == "DIC" ~ "12")) %>% 
  mutate(messy_dates = file %in% messy_dates,
         year_month = paste(year, month, sep = "_"))

# READ ALL
plan(multisession, workers = 14)

metadata %>% 
  select(year, month, path) %>%
  nest(data = path) %$% 
  future_pwalk(.l = list(data = data, year = year, month = month), clean_vms)

plan(sequential)




system("date >> scripts/vms/clean.log")









