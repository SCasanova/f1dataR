#' Load Lap by Lap Time Data
#'
#' @description Loads basic lap-by-lap time data for all drivers in a given season
#' and round. Lap time data is available from 1996 onward. Use `.load_laps()` for a uncached version.
#'
#' @param season number from 1996 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season selected) and defaults
#' to most recent.  Also accepts `'last'`.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, use `round`.
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with columns driver_id (unique and recurring), position
#' during lap, time (in clock form), lap number, time (in seconds), and season.
load_laps <- function(season = get_current_season(), round = "last", race = lifecycle::deprecated()) {
  # Deprecation Check
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop("1.4.0", "load_laps(race)", "load_laps(round)")
  }

  # Parameter Check
  if (season != "current" && (season < 1996 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 1996 and {get_current_season()} (or use "current")')
  }

  # Function Code
  url <- glue::glue("{season}/{round}/laps.json?limit=1000",
    season = season, round = round
  )
  data <- get_ergast_content(url)

  total <- data$MRData$total %>% as.numeric()
  if (total - 1000 > 0 && total - 1000 <= 1000) {
    lim <- total - 1000
    url2 <- glue::glue("{season}/{round}/laps.json?limit={lim}&offset=1000",
      lim = lim, season = season, round = round
    )
    data2 <- get_ergast_content(url2)

    full <- dplyr::bind_rows(data$MRData$RaceTable$Races$Laps[[1]][2], data2$MRData$RaceTable$Races$Laps[[1]][2])
  } else {
    full <- data$MRData$RaceTable$Races$Laps[[1]][2]
  }

  laps <- tibble::tibble()
  season_text <- ifelse(season == "current", get_current_season(), season)
  for (i in seq_len(nrow(full))) {
    laps <- dplyr::bind_rows(
      laps,
      full[[1]][i][[1]] %>%
        dplyr::mutate(
          lap = i,
          time_sec = time_to_sec(.data$time),
          season = season_text
        )
    )
  }
  laps %>%
    tibble::tibble() %>%
    janitor::clean_names()
}
