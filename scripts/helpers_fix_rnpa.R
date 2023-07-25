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

fix_rnpa <- function(rnpa, length = 8){
  rnpa[is.na(rnpa)] <- "_"
  lengths <- stringr::str_length(rnpa)
  missing <- pmax(length - lengths, 0)
  zeroes <- purrr::map_chr(missing, ~paste(numeric(length = .x), collapse = ""))
  out <- paste0(zeroes, rnpa)
  return(out)
}
