################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Description
# Build a function to clean cooperative names. The steps are to:
# - Fix any weird characters
# - Convert all instances of Sociecad Cooperativa or S.C.P.P. ... to SCPP
# - Remove all SC DE RL DE CV things
################################################################################


clean_eu_names <- function(x) {
  
  out <-  x %>% 
    str_to_upper() %>% 
    str_squish() %>% 
    str_remove_all(pattern= ",") %>% 
    str_replace_all(pattern= "Á", replacement = "A") %>% 
    str_replace_all(pattern= "É", replacement = "E") %>% 
    str_replace_all(pattern= "Í", replacement = "I") %>% 
    str_replace_all(pattern= "Ó", replacement = "O") %>% 
    str_replace_all(pattern= "Ú", replacement = "U") %>% 
    str_replace_all(pattern= "Ñ", replacement = "N") %>% 
    # Common abbreviations
    str_replace_all(pattern = "BCS\\.?\\s", replacement = "BAJA CALIFORNIA SUR ") %>% 
    str_replace_all(pattern = "BC\\.?\\s?", replacement = "BAJA CALIFORNIA ") %>% 
    str_replace_all(pattern = "OCC\\.?\\s", replacement = "OCCIDENTAL ") %>% 
    str_replace_all(pattern = "CALIF\\.?\\s", replacement = "CALIFORNIA ") %>% 
    # Prefixes
    str_remove(pattern = "SCPP") %>% 
    str_remove(pattern = "UPP") %>% 
    str_remove(pattern = "S\\.E\\.P\\.P\\.E\\.?") %>% 
    str_remove(pattern = "S\\.C\\.P\\.P\\.?") %>% 
    str_remove(pattern = "U\\.P\\.P\\.E\\.?") %>%
    str_remove(pattern = "U\\.P\\.P\\.?") %>%
    str_remove(pattern = "SOCIEDAD COOPERATIVA DE PRODUCCION PESQUERA") %>% 
    str_remove(pattern = "UNIDAD DE PRODUCCION PESQUERA EJIDAL") %>% 
    str_remove(pattern = "UNIDAD DE PRODUCCION PESQUERA") %>% 
    str_squish() %>% 
    # Suffixes
    str_remove(pattern = "S\\.C\\.L\\.?") %>%
    str_remove(pattern = "S\\.?\\s?P\\.?\\s?R\\.? DE R\\.?\\s?L\\.") %>%
    str_remove(pattern = "S\\.?\\s?C\\.? DE R\\.?\\s?L\\.") %>%
    str_remove(pattern = "S\\.P\\.R\\. DE R\\.I\\.") %>%
    str_remove(pattern = "S\\.P\\.R\\. DE R\\.") %>%
    str_remove(pattern = "S\\.P\\.R\\.?") %>%
    str_remove(pattern = "S\\.A\\.?") %>%
    str_remove(pattern = "S\\.") %>%
    str_remove(pattern = "DE R\\.L\\.") %>%
    str_remove(pattern = "DE R\\.I\\.") %>%
    str_remove(pattern = "DE C\\.V\\.") %>%
    str_remove_all(pattern = "\\.\\s") %>% 
    str_remove_all(pattern = "P.R DE R.L.") %>% 
    str_squish() %>% 
    # Suffixes without points in them
    str_remove(pattern = "SPR DE RL") %>%
    str_remove(pattern = "DE R") %>%
    # str_remove_all(pattern = "[:punct:]") %>% 
    str_squish() %>% 
    # Random things
    str_remove_all(pattern = "ERIZO ROJO Y PEPINO") %>% 
    str_remove_all(pattern = "PEPINO Y CANGREJO") %>% 
    str_remove_all(pattern = "NUM[:digit:]") %>% 
    str_remove_all(pattern = '"') %>% 
    str_squish()
  
  return(out)
}
