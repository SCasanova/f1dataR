#' Load Pitstop Data
#'
#' @description Loads pit stop info (number, lap, time elapsed) for a given race
#' in a season. Pit stop data is available from 2011 onward.
#'
#' @param season number from 2011 to current season (defaults to current season).
#' @param round number from 1 to the number of rounds in the season, and defaults
#' to most recent. Also accepts `'last'`.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, please use `round`.
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with columns driver_id, lap, stop (number), time (of day),
#' and stop duration, or NULL if the request fails. Results are paginated automatically,
#' so races with more than 100 pit stops are returned in full. Note that `lap`, `stop`,
#' and `duration` are returned by the API as strings and are therefore all **character**
#' columns, not numeric.
load_pitstops <- function(
  season = get_current_season(),
  round = "last",
  race = lifecycle::deprecated()
) {
  # Deprecation check
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop(
      "1.4.0",
      "load_pitstops(race)",
      "load_pitstops(round)"
    )
  }

  # Parameter Check
  check_season_arg(season, 2011)
  check_round_arg(round)

  # Function Code
  lim <- 100
  url <- glue::glue(
    "{season}/{round}/pitstops.json",
    season = season,
    round = round
  )
  data <- get_jolpica_content(url, parameters = list(limit = lim))

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  if (length(data$MRData$RaceTable$Races$PitStops) == 0) {
    cli::cli_alert_warning("No pit stop data available for this season/round.")
    return(NULL)
  }

  full <- data$MRData$RaceTable$Races$PitStops[[1]]

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

    if (length(data$MRData$RaceTable$Races$PitStops) == 0) {
      break
    }

    full <- dplyr::bind_rows(full, data$MRData$RaceTable$Races$PitStops[[1]])
  }

  full %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
}
