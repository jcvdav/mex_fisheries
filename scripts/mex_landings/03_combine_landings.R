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
  tidyverse
)

# Load and define functions ----------------------------------------------------
source(here("scripts", "00_setup.R"))

# Load data --------------------------------------------------------------------
stuart <- readRDS(here("data", "mex_landings", "clean", "mex_conapesca_avisos_2000_2019.rds")) |> 
  filter(year_cut <= 2017)

apertura <- readRDS(here("data", "mex_landings", "clean", "mex_conapesca_apertura_2018_present.rds"))

months <- tibble(month_cut = c("ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"),
                 month = 1:12) 

## PROCESSING ##################################################################

# Combine and select columns ---------------------------------------------------
landings <- bind_rows(stuart,
                      apertura) |> 
  left_join(months, by = "month_cut")

# Fix dates --------------------------------------------------------------------

dates <- landings$receipt_date

# Extract parts of dates
first <- str_extract(dates, "[:digit:]{1,2}(?=/)") |> as.numeric()
second <- str_extract(dates, "(?<=/)[:digit:]{1,2}(?=/)") |> as.numeric()
month <- landings$month

landings$receipt_day <- NA
landings$receipt_month <- NA
## both are the same and less thn 12 -------------------------------------------
# If first and second are the same and equal to or less than 12, then it doesn't matter which one we assign
landings$receipt_day[which(first == second & first <= 12)] <- first[which(first == second & first <= 12)]
landings$receipt_month[which(first == second & first <= 12)] <- second[which(first == second & first <= 12)]
cat("There are now", round(sum(is.na(landings$receipt_day)) / nrow(landings) * 100, 2), "% observations with dates not yet determined\n")
unique(landings$receipt_month)

## One is greater than 12, the other one isn't ---------------------------------
# If the first is greater than 12 and the second is less than 12
landings$receipt_day[first > 12 & second <= 12] <- first[first > 12 & second <= 12] # then first is the receipt_day
landings$receipt_month[first > 12 & second <= 12] <- second[first > 12 & second <= 12] # and the second is the receipt_month

# If the second is greater than 12 and the first is less than 12
landings$receipt_day[second > 12 & first <= 12] <- second[second > 12 & first <= 12] # then second is the receipt_day
landings$receipt_month[second > 12 & first <= 12] <- first[second > 12 & first <= 12] # first is the month

cat("There are now", round(sum(is.na(landings$receipt_day)) / nrow(landings) * 100, 2), "% observations with dates not yet determined\n")
unique(landings$receipt_month)

## Match to month_cut ----------------------------------------------------------
# We now deal with the cases where both first and second are smaller than 12, but don't match.
# For example, april 5 can be represented as 05/04 or 05/04. We can hopefully
# match one of the character groups to the month_cut (when the data were produced by conapesca)

# Cases where the digit might be a month
first_matches_month <- first == month
second_matches_month <- second == month

# If the second one matches the month, then the first one must be the receipt_day
landings$receipt_day[which(is.na(landings$receipt_day) & second_matches_month)] <- first[which(is.na(landings$receipt_day) & second_matches_month)]
# If the first one matches the month, then we'll use the first one as the month
landings$receipt_month[which(is.na(landings$receipt_month) & first_matches_month)] <- first[which(is.na(landings$receipt_month) & first_matches_month)]
# If the first one matches the month, then the second one must be the receipt_day
landings$receipt_day[which(is.na(landings$receipt_day) & first_matches_month)] <- second[which(is.na(landings$receipt_day) & first_matches_month)]
# If the second one matches the month, then we'll use the second one as the. month
landings$receipt_month[which(is.na(landings$receipt_month) & second_matches_month)] <- second[which(is.na(landings$receipt_month) & second_matches_month)]

cat("There are", round(sum(is.na(landings$receipt_day)) / nrow(landings) * 100, 2), "% observations with dates not determined\n")
unique(landings$receipt_month)
cat("No further attempts of matching receipt_days\n")

final_landings <- landings |> 
  mutate(receipt_date = ymd(paste(year_cut, receipt_month, receipt_day, sep = "-"))) |> 
  select(state,
         office_name,
         landing_site,
         landing_site_key,
         year = year_cut,
         month = month,
         receipt_date,
         period_start,
         period_end,
         eu_rnpa,
         eu_name = economic_unit,
         fleet,
         acuaculture_production,
         vessel_rnpa,
         vessel_name,
         main_species_group,
         landed_weight,
         live_weight,
         value)

## EXPORT ######################################################################

# Export file ------------------------------------------------------------------
saveRDS(object = final_landings,
        file = here("data", "mex_landings", "clean", "mex_landings_2000_present.rds"))
