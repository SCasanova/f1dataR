#' Load Pitstop Data
#'
#' @description Loads pit stop info (number, lap, time elapsed) for a given race
#' in a season. Pit stop data is available from 2012 onward.
#' Call `.load_pitstops()` for an uncached version.
#'
#' @param season number from 2011 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season selected) and defaults
#' to most recent.Also accepts `'last'`.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, please use `round`.
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with columns driver_id, lap, stop (number), time (of day),
#' and stop duration
load_pitstops <- function(season = get_current_season(), round = "last", race = lifecycle::deprecated()) {
  # Deprecation check
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop("1.4.0", "load_pitstops(race)", "load_pitstops(round)")
  }

  # Parameter Check
  if (season != "current" && (season < 2011 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 2011 and {get_current_season()} (or use "current")')
  }

  # Function Code
  url <- glue::glue("{season}/{round}/pitstops.json?limit=100",
    season = season, round = round
  )
  data <- get_jolpica_content(url)

  if (is.null(data)) {
    return(NULL)
  }

  data$MRData$RaceTable$Races$PitStops[[1]] %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
}
