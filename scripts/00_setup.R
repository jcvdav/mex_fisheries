##########################
## Paths to directories ##
##########################

# Check for OS
sys_path <- ifelse(Sys.info()["sysname"]=="Windows", "G:/","/Volumes/GoogleDrive")

# Path to emLab data folder
data_path <- file.path(sys_path,"Shared drives/emlab/data")

# Path to this project folder
project_path <- file.path(sys_path,"Shared drives/emlab/projects/current-projects/mex-fisheries")

# Functions
fix_rnpa <- function(rnpa){
  lengths <- stringr::str_length(rnpa)
  missing <- pmax(8 - lengths, 0)
  zeroes <- purrr::map_chr(missing, ~paste(numeric(length = .x), collapse = ""))
  out <- paste0(zeroes, rnpa)
  return(out)
}
