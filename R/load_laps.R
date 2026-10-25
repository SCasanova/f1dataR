#' Load Lap by Lap Time Data
#'
#' @description Loads basic lap-by-lap time data for all drivers in a given season
#' and round. Lap time data is available from 1996 onward.
#'
#' @param season number from 1996 to current season (defaults to current season). Also accepts `"current"`.
#' @param round number from 1 to the number of rounds in the season and defaults
#' to most recent.  Also accepts `'last'`.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, use `round`.
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with columns driver_id (unique and recurring), position
#' during lap (character), time (in clock form, `time`), lap number (`lap`, taken from the API's
#' `number` field), time in seconds (`time_sec`), and season. Returns `NULL` on API failure.
#' Note that `season` is numeric when the caller passed a numeric `season` or `"current"`, but
#' will be character if a character `season` string (e.g. `"2021"`) was passed in, since the
#' original argument is echoed back rather than coerced.
load_laps <- function(
  season = get_current_season(),
  round = "last",
  race = lifecycle::deprecated()
) {
  # Deprecation Check
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop("1.4.0", "load_laps(race)", "load_laps(round)")
  }

  # Parameter Check
  check_season_arg(season, 1996)
  check_round_arg(round)

  lim <- 100

  # Function Code
  url <- glue::glue(
    "{season}/{round}/laps.json",
    season = season,
    round = round
  )
  data <- get_jolpica_content(url, parameters = list("limit" = lim))

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  if (length(data$MRData$RaceTable$Races$Laps) == 0) {
    cli::cli_alert_warning("No lap data available for this season/round.")
    return(NULL)
  }

  # Jolpica paginates by driver-lap timing row, not by lap, so a single lap's
  # timing rows can be split across pages (e.g. non-20-car seasons). Collect all
  # pages of `Laps` (each a data.frame of `number` + `Timings`) first, then
  # aggregate `Timings` per `number` once all pages are in hand.
  pages <- list(data$MRData$RaceTable$Races$Laps[[1]])
  received <- sum(vapply(pages[[1]]$Timings, nrow, integer(1)))

  # Iterate over the request until completed
  while (received < total) {
    offset <- offset + lim

    data <- get_jolpica_content(
      url,
      parameters = list(limit = lim, offset = offset)
    )

    if (is.null(data)) {
      return(NULL)
    }

    if (length(data$MRData$RaceTable$Races$Laps) == 0) {
      break
    }

    page <- data$MRData$RaceTable$Races$Laps[[1]]
    pages[[length(pages) + 1]] <- page
    received <- received + sum(vapply(page$Timings, nrow, integer(1)))
  }

  full <- dplyr::bind_rows(pages)

  season_text <- ifelse(season == "current", get_current_season(), season)

  laps <- full %>%
    dplyr::mutate(lap = as.numeric(.data$number)) %>%
    dplyr::group_by(.data$lap) %>%
    dplyr::summarise(
      Timings = list(dplyr::bind_rows(.data$Timings)),
      .groups = "drop"
    ) %>%
    dplyr::arrange(.data$lap) %>%
    tidyr::unnest(cols = "Timings") %>%
    dplyr::mutate(
      time_sec = time_to_sec(.data$time),
      season = season_text
    )

  laps %>%
    tibble::tibble() %>%
    janitor::clean_names()
}
