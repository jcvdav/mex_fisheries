files <- list.files(path = here("data", "mex_landings", "raw", "CONAPESCA_apertura"),
                    pattern = "*.xlsx",
                    full.names = T)


landings <- map_dfr(files, readxl::read_excel, col_types = "text") %>% 
  janitor::clean_names()
