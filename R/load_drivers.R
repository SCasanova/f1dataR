#' Load Driver Info (not cached)
#'
#' Loads driver info for all participants in a given season.
#' This funtion does not export, only the cached version.
#'
#' @param season number from 1950 to 2022 (defaults to current season). All
#' drivers after 2014 will have a permanent number.
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId (unique and recurring), first name,
#' last name, nationality, date of birth (yyyy-mm-dd format), driver code, and
#' permanent number (for post-2014 drivers).

.load_drivers <- function(season = 2022){
  res <-  httr::GET(glue::glue('http://ergast.com/api/f1/{season}/drivers.json?limit=40', season = season))
  data <- jsonlite::fromJSON(rawToChar(res$content))
  data$MRData$DriverTable$Drivers %>%
    dplyr::select(driverId, givenName, familyName, nationality, dateOfBirth, code, permanentNumber) %>%
    tibble::as_tibble()
}

#' Load Driver Info
#'
#' Loads driver info for all participants in a given season.
#'
#' @param season number from 1950 to 2022 (defaults to current season). All
#' drivers after 2014 will have a permanent number.
#' @return A dataframe with columns driverId (unique and recurring), first name,
#' last name, nationality, date of birth (yyyy-mm-dd format), driver code, and
#' permanent number (for post-2014 drivers).

#' @export

load_drivers <- memoise::memoise(.load_drivers)

