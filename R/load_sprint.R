#' Load Sprint Results
#'
#' Loads final race results for a given year and round. Note not all rounds have
#' sprint results. Use `.load_sprint()` for an uncached version of this function.
#'
#' @param season number from 2021 to current season  (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent. Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
#' @return A dataframetibble with columns driver_id, constructor_id, points awarded, finishing position,
#' grid position, laps completed, race status (finished or otherwise), gap to
#' first place, fastest lap, fastest lap time, fastest lap in seconds,
#' or NULL if no sprint exists for this season/round combo
load_sprint <- function(season = get_current_season(), round = "last") {
  if (season != "current" && (season < 2021 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 2021 and {get_current_season()} (or use "current")')
  }

  url <- glue::glue("{season}/{round}/sprint.json?limit=40",
    season = season, round = round
  )

  data <- get_jolpica_content(url)

  if (is.null(data)) {
    return(NULL)
  }

  if (length(data$MRData$RaceTable$Races) == 0) {
    cli::cli_alert_warning(glue::glue("No Sprint data for season = {season}, round = {round}",
      season = season, round = round
    ))
    return(NULL)
  }

  data <- data$MRData$RaceTable$Races$SprintResults[[1]]

  data %>%
    tidyr::unnest(
      cols = c("Driver", "Constructor", "Time", "FastestLap"),
      names_repair = "universal"
    ) %>%
    tidyr::unnest(
      cols = c("Time"),
      names_repair = "universal"
    ) %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    dplyr::select(
      "driverId",
      "constructorId",
      "points",
      "position",
      "grid",
      "laps",
      "status",
      "position",
      gap = "time...21",
      "lap",
      fastest = "time...23"
    ) %>%
    dplyr::mutate(time_sec = time_to_sec(.data$fastest)) %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
}
