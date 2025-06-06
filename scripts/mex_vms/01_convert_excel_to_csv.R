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
  data.table,
  readxl,
  magrittr,
  tidyverse
)

## PROCESSING ##################################################################
# Define read-write function ---------------------------------------------------
rw <- function(x) {
  new_file <- str_replace_all(x, "xlsx", "csv")
  
  if(!file.exists(new_file)) {
    data <- read_excel(
    path = x,
    sheet = 1,
    col_types = c(
      "text",
      "text",
      "text",
      "text",
      "date",
      "text",
      "text",
      "text",
      "text"
    ),
    na = "NULL"#,
    # col_names = c(
      # "name",
      # "rnpa",
      # "port",
      # "economic_unit",
      # "datetime",
      # "lat",
      # "lon",
      # "speed",
      # "course"
    # )
  )
  
  fwrite(x = data, file = new_file, na = "NULL")
  
  
  } else {print(paste("File", basename(new_file), "already exists, skipping..."))}
  
  log_path <- here("data", "mex_vms", "raw", "xls_to_csv_logs.log")
  system(paste("date >>", log_path))

}

# Find all excel sheets that need to be converted ------------------------------
paths <-
  list.files(
    path = here("data", "mex_vms", "raw"),
    recursive = T,
    pattern = "*.xlsx",
    full.names = T
  )

# Execute
walk(paths, safely(rw))
