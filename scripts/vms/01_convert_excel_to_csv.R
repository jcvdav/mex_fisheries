######################################################
#title#
######################################################
# 
# Purpose
#
######################################################
## Set up
# Load packages
library(data.table)
library(readxl)
library(magrittr)
library(tidyverse)

rw <- function(x, y){
  data <- read_excel(path = x,
                     sheet = 1,
                     skip = 1,
                     col_types = c("text",
                                   "text",
                                   "text",
                                   "text",
                                   "date",
                                   "numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric"),
                     na = "NULL",
                     col_names = c("name", "rnpa", "port", "economic_unit", "datetime", "lat", "lon", "speed", "course"))
  
  fwrite(x = data, file = y, na = "NULL")
}

paths <- list.files(path = file.path(data_sets, "mex_fisheries", "mex_vms", "raw"),
                    recursive = T,
                    pattern = "*.xlsx",
                    full.names = T)

new_file <- str_replace_all(paths, "xlsx", "csv")

walk2(paths, new_file, rw)



system("date >> scripts/vms/clean.log")
