#' Load Standings
#'
#' Loads standings at the end of a given season and round for drivers' or
#' constructors' championships. Use `.load_standings()` for an uncached version of this function.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @param type select `'drivers'` or `'constructors'` championship data. Defaults to
#' `'drivers'`
#' @importFrom magrittr "%>%"
#' @keywords internal
#' @return A tibble with columns driver_id (or constructor_id), position,
#' points, wins (and constructorsId in the case of drivers championship).
.load_standings <- function(season = get_current_season(), round = 'last', type = 'driver'){
  if(season != 'current' & (season < 2003 | season > get_current_season())){
    cli::cli_abort('{.var season} must be between 1950 and {get_current_season()} (or use "current")')
    # stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
    #                 current=get_current_season()))
  }

  url <- glue::glue('{season}/{round}/{type}Standings.json?limit=40',
                    season = season, round = round, type = type)
  data <- get_ergast_content(url)

  if(type == 'driver'){
    data$MRData$StandingsTable$StandingsLists$DriverStandings[[1]] %>%
      tidyr::unnest(cols = c("Driver")) %>%
      dplyr::select("driverId", "position", "points", "wins", "Constructors") %>%
      tidyr::unnest(cols = c("Constructors")) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select("driverId", "position", "points", "wins", "constructorId") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else if (type == 'constructor'){
    data$MRData$StandingsTable$StandingsLists$ConstructorStandings[[1]] %>%
      tidyr::unnest(cols = c("Constructor")) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select("constructorId", "position", "points", "wins") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }
}

#' @import .load_standings title description params return
#' @export
#' examples
#' # Get the driver standings at the end of 2021
#' load_standings(2021, 'last', 'drivers')
#' 
#' # Get constructor standings at the end of 1997
#' load_standings(1997, 'last', 'constructors')
load_standings <- memoise::memoise(.load_standings)
