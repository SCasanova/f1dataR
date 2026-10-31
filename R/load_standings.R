#' Load Standings
#'
#' @description Loads standings at the end of a given season and round for drivers' or
#' constructors' championships.
#'
#' @param season number from 2003 to current season (or the word 'current') (defaults to current season).
#' @param round number from 1 to the number of rounds in the season, and defaults
#' to most recent. Also accepts `'last'`.
#' @param type select `'driver'` or `'constructor'` championship data. Defaults to
#' `'driver'`
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with columns driver_id (or constructor_id), position,
#' points, wins (and constructor_id in the case of drivers championship), or NULL if the request fails.
#' `position`, `points`, and `wins` are returned by the API as strings and are therefore all
#' **character** columns, not numeric. For the drivers' championship, a driver who raced for more
#' than one constructor in the season will appear as multiple rows (one per constructor), since the
#' underlying `Constructors` field is unnested.
load_standings <- function(
  season = get_current_season(),
  round = "last",
  type = "driver"
) {
  check_season_arg(season, 2003)
  check_round_arg(round)

  type <- match.arg(tolower(type), c("driver", "constructor"))

  url <- glue::glue(
    "{season}/{round}/{type}Standings.json",
    season = season,
    round = round,
    type = type
  )

  lim <- 100
  data <- get_jolpica_content(url, parameters = list(limit = lim))

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  standings_col <- if (type == "driver") {
    "DriverStandings"
  } else {
    "ConstructorStandings"
  }
  full <- data$MRData$StandingsTable$StandingsLists[[standings_col]][[1]]

  # Iterate over the request until completed
  while (nrow(full) < total) {
    offset <- offset + lim

    data <- get_jolpica_content(
      url,
      parameters = list(limit = lim, offset = offset)
    )

    if (is.null(data)) {
      return(NULL)
    }

    full <- dplyr::bind_rows(
      full,
      data$MRData$StandingsTable$StandingsLists[[standings_col]][[1]]
    )
  }

  if (type == "driver") {
    full %>%
      tidyr::unnest(cols = c("Driver")) %>%
      dplyr::select(
        "driverId",
        "position",
        "points",
        "wins",
        "Constructors"
      ) %>%
      tidyr::unnest(cols = c("Constructors")) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select(
        "driverId",
        "position",
        "points",
        "wins",
        "constructorId"
      ) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else if (type == "constructor") {
    full %>%
      tidyr::unnest(cols = c("Constructor")) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select("constructorId", "position", "points", "wins") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }
}
