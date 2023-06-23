#' Load Driver Info
#'
#' Loads driver info for all participants in a given season. Use `.load_drivers()` for an uncached version of this function.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @importFrom magrittr "%>%"
#' @keywords internal
#' @return A tibble with columns driver_id (unique and recurring), first name,
#' last name, nationality, date of birth (yyyy-mm-dd format), driver code, and
#' permanent number (for post-2014 drivers).
.load_drivers <- function(season = get_current_season()){
  if(season != 'current' & (season < 1950 | season > get_current_season())){
    cli::cli_abort('{.var season} must be between 1950 and {get_current_season()} (or use "current")')
    # stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
    #                 current=get_current_season()))
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

#' @inherit .load_drivers title description params return
#' @export
#' @examples
#' #Load the drivers appearing in this season's data:
#' load_drivers()
#'
#' #Load the drivers who participated in the first year of Formula 1:
#' load_drivers(1950)
load_drivers <- memoise::memoise(.load_drivers)
