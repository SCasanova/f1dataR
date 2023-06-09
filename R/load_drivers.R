#' Load Driver Info (not cached)
#'
#' Loads driver info for all participants in a given season.
#' This function does not export, only the cached version.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @importFrom magrittr "%>%"
#' @return A tibble with columns driver_id (unique and recurring), first name,
#' last name, nationality, date of birth (yyyy-mm-dd format), driver code, and
#' permanent number (for post-2014 drivers).

.load_drivers <- function(season = 'current'){
  if(season != 'current' & (season < 1950 | season > get_current_season())){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
                    current=get_current_season()))
  }

  url <- glue::glue('{season}/drivers.json?limit=40',
                    season = season)
  data <- get_ergast_content(url)

  if(season<2014){
    data$MRData$DriverTable$Drivers %>%
      dplyr::select("driverId",
                    "givenName",
                    "familyName",
                    "nationality",
                    "dateOfBirth") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else{
    data$MRData$DriverTable$Drivers %>%
      dplyr::select("driverId",
                    "givenName",
                    "familyName",
                    "nationality",
                    "dateOfBirth",
                    "code",
                    "permanentNumber") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }

}

#' Load Driver Info
#'
#' Loads driver info for all participants in a given season.
#'
#' @param season number from 1950 to current season (defaults to current season). All
#' drivers after 2014 will have a permanent number.
#' @return A tibble with columns driver_id (unique and recurring), first name,
#' last name, nationality, date of birth (yyyy-mm-dd format), driver code, and
#' permanent number (for post-2014 drivers).

#' @export

load_drivers <- memoise::memoise(.load_drivers)
