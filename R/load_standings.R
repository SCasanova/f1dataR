#' Load Standings (not cached)
#'
#' Loads standings at the end of a given season and round for drivers' or
#' constructors' championships.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @param type select drivers or constructors championship data. Defaults to
#' drivers
#' @importFrom magrittr "%>%"
#' @return A tibble with columns driver_id (or constructor_id), position,
#' points, wins and constructorsId in the case of drivers championship.

.load_standings <- function(season = 'current', round = 'last', type = 'driver'){
  if(season != 'current' & (season < 2003 | season > get_current_season())){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
                    current=get_current_season()))
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

#' Load Standings
#'
#' Loads standings at the end of a given season and round for drivers' or
#' constructors' championships.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @param type select drivers or constructors championship data. Defaults to
#' drivers
#' @importFrom magrittr "%>%"
#' @return A tibble with columns driver_id (or constructor_id), position,
#' points, wins and constructorsId in the case of drivers championship.
#' @export

load_standings <- memoise::memoise(.load_standings)

