################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Build polygons shwon in:
# https://www.scielo.org.mx/img/revistas/cuat/v15n1//2007-7858-cuat-15-01-6-gf1.png
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
pacman::p_load(here,
               sf,
               tidyverse)

# Load data --------------------------------------------------------------------
mex <-
  st_read(
    dsn = here(
      "data",
      "spatial_features",
      "raw",
      "World_EEZ_v12_20231025_gpkg",
      "eez_v12.gpkg"
    )
  ) %>%
  filter(ISO_SOV1 == "MEX") %>% 
  select(ISO_SOV1)


## PROCESSING ##################################################################

# X ----------------------------------------------------------------------------
r1 <- st_intersection(x = mex,
                      y = st_sfc(st_polygon(list(
                        matrix(
                          c(
                            -130, 33,
                            -117, 33,
                            -109.85, 22.9,
                            -110, 22,
                            -115, 22,
                            -120, 22,
                            -130, 33),
                          ncol = 2,
                          byrow = T
                        )
                      )),
                      crs = 4326))

# X ----------------------------------------------------------------------------
r2 <- st_intersection(x = mex,
                      y = st_sfc(st_polygon(list(
                        matrix(
                          c(-117, 33,
                            -109.85, 22.9,
                            -110, 22,
                            -103, 22,
                            -112.5, 33,
                            -117, 33),
                          ncol = 2,
                          byrow = T
                        )
                      )),
                      crs = 4326))

# X ----------------------------------------------------------------------------
r3 <- st_intersection(x = mex,
                      y = st_sfc(st_polygon(list(
                        matrix(
                          c(
                            -115, 22,
                            -110, 22,
                            -103, 22,
                            -97, 15.8,
                            # -100, 13,
                            -99, 12.5,
                            -120, 15,
                            -120, 22,
                            -115, 22),
                          ncol = 2,
                          byrow = T
                        )
                      )),
                      crs = 4326))

# X ----------------------------------------------------------------------------
r4 <- st_intersection(x = mex,
                      y = st_sfc(st_polygon(list(
                        matrix(
                          c(-97, 15.8,
                            -94.5, 17,
                            -90, 14,
                            -95, 10,
                            # -100, 13,
                            -99, 12.5,
                            -97, 15.8),
                          ncol = 2,
                          byrow = T
                        )
                      )),
                      crs = 4326))

# X ----------------------------------------------------------------------------
r5 <- st_intersection(x = mex,
                      y = st_sfc(st_polygon(list(
                        matrix(
                          c(-100, 30,
                            -91.95, 30,
                            -91.95, 18.5,
                            -97, 17,
                            -100, 30),
                          ncol = 2,
                          byrow = T
                        )
                      )),
                      crs = 4326))

# X ----------------------------------------------------------------------------
r6 <- st_intersection(x = mex,
                      y = st_sfc(st_polygon(list(
                        matrix(
                          c(-91.95, 28,
                            -80, 28,
                            -80, 15,
                            -91.95, 15,
                            -91.95, 18.5,
                            -91.95, 28),
                          ncol = 2,
                          byrow = T
                        )
                      )),
                      crs = 4326))

regions <- bind_rows(r1, r2, r3, r4, r5, r6, .id = "region") %>%
  select(region) %>% 
  mutate(region = as.numeric(region))

## VISUALIZE ###################################################################

# X ----------------------------------------------------------------------------
ggplot() +
  geom_sf(data = regions,
          aes(fill = factor(region)), alpha = 0.5) +
  theme_bw()

## RUN SOME TESTS ##############################################################
# Are all geometries valid? ----------------------------------------------------
all(st_is_valid(regions))
# Are all geometries non-empty? ------------------------------------------------
all(!st_is_empty(regions))

## EXPORT ######################################################################
# Save as geopackage -----------------------------------------------------------
st_write(
  obj = regions,
  dsn = here("data", "spatial_features", "clean", "mexico_fishing_regions.gpkg"),
  delete_dsn = T
)
