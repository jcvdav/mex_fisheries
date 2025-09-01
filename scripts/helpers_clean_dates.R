fix_dates <- function(data, date_to_fix){
  # Date column to fix
  dates <- date_to_fix
  # Known month and year from cuts
  month <- data$month
  year <- data$year_cut
  
  n_dates <- length(dates)
  
  # Extract parts of dates
  first <- str_extract(dates, "[:digit:]{1,2}(?=/)") |> as.numeric()
  second <- str_extract(dates, "(?<=/)[:digit:]{1,2}(?=/)") |> as.numeric()
  second_is_zero <- second == 0
  second[second_is_zero] <- NA
  
  
  fixed_day <- fixed_month <- numeric(length = n_dates)
  fixed_day[] <- NA
  fixed_month[] <- NA
  
  ## both are the same and less thn 12 -------------------------------------------
  # If first and second are the same and equal to or less than 12, then it doesn't matter which one we assign
  fixed_day[which(first == second & first <= 12)] <- first[which(first == second & first <= 12)]
  fixed_month[which(first == second & first <= 12)] <- second[which(first == second & first <= 12)]
  cat("There are now", round(sum(is.na(fixed_day)) / nrow(landings) * 100, 2), "% observations with dates not yet determined\n")
  sort(unique(fixed_month))
  
  ## One is greater than 12, the other one isn't ---------------------------------
  # If the first is greater than 12 and the second is less than 12
  fixed_day[which(first > 12 & second <= 12)] <- first[which(first > 12 & second <= 12)] # then first is the fixed_day
  fixed_month[which(first > 12 & second <= 12)] <- second[which(first > 12 & second <= 12)] # and the second is the fixed_month
  
  # If the second is greater than 12 and the first is less than 12
  fixed_day[which(second > 12 & first <= 12)] <- second[which(second > 12 & first <= 12)] # then second is the fixed_day
  fixed_month[which(second > 12 & first <= 12)] <- first[which(second > 12 & first <= 12)] # first is the month
  
  cat("There are now", round(sum(is.na(fixed_day)) / nrow(landings) * 100, 2), "% observations with dates not yet determined\n")
  sort(unique(fixed_month))
  
  ## Match to month_cut ----------------------------------------------------------
  # We now deal with the cases where both first and second are smaller than 12, but don't match.
  # For example, april 5 can be represented as 05/04 or 05/04. We can hopefully
  # match one of the character groups to the month_cut (when the data were produced by conapesca)
  
  # Cases where the digit might be a month
  first_matches_month <- first == month
  second_matches_month <- second == month
  
  # If the second one matches the month, then the first one must be the fixed_day
  fixed_day[which(is.na(fixed_day) & second_matches_month)] <- first[which(is.na(fixed_day) & second_matches_month)]
  # If the first one matches the month, then we'll use the first one as the month
  fixed_month[which(is.na(fixed_month) & first_matches_month)] <- first[which(is.na(fixed_month) & first_matches_month)]
  # If the first one matches the month, then the second one must be the fixed_day
  fixed_day[which(is.na(fixed_day) & first_matches_month)] <- second[which(is.na(fixed_day) & first_matches_month)]
  # If the second one matches the month, then we'll use the second one as the. month
  fixed_month[which(is.na(fixed_month) & second_matches_month)] <- second[which(is.na(fixed_month) & second_matches_month)]
  
  cat("There are", round(sum(is.na(fixed_day)) / nrow(landings) * 100, 2), "% observations with dates not determined\n")
  sort(unique(fixed_month))
  cat("No further attempts\n")
  cat("\n")
  
  fixed_date <- ymd(paste(year, fixed_month, fixed_day, sep = "-"), quiet = T)
  
  return(fixed_date)
}
