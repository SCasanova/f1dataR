#' Load Standings
#'
#' @description Loads standings at the end of a given season and round for drivers' or
#' constructors' championships. Use `.load_standings()` for an uncached version of this function.
#'
#' @param season number from 2003 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent. Also accepts `'last'`.
#' @param type select `'driver'` or `'constructor'` championship data. Defaults to
#' `'driver'`
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with columns driver_id (or constructor_id), position,
#' points, wins (and constructors_id in the case of drivers championship).
load_standings <- function(season = get_current_season(), round = "last", type = "driver") {
  if (season != "current" && (season < 2003 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 2003 and {get_current_season()} (or use "current")')
  }

  if (!(type %in% c("driver", "constructor"))) {
    cli::cli_abort('{.var type} must be either "driver" or "constructor"')
  }

  url <- glue::glue("{season}/{round}/{type}Standings.json?limit=40",
    season = season, round = round, type = type
  )

  data <- get_jolpica_content(url)

  if (is.null(data)) {
    return(NULL)
  }

  if (type == "driver") {
    data$MRData$StandingsTable$StandingsLists$DriverStandings[[1]] %>%
      tidyr::unnest(cols = c("Driver")) %>%
      dplyr::select("driverId", "position", "points", "wins", "Constructors") %>%
      tidyr::unnest(cols = c("Constructors")) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select("driverId", "position", "points", "wins", "constructorId") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else if (type == "constructor") {
    data$MRData$StandingsTable$StandingsLists$ConstructorStandings[[1]] %>%
      tidyr::unnest(cols = c("Constructor")) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select("constructorId", "position", "points", "wins") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }
}
