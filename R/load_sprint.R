#' Load Sprint Results
#'
#' Loads final sprint race results for a given year and round. Note not all rounds have
#' sprint results.
#'
#' @param season number from 2021 to current season (or the word 'current') (defaults to current season).
#' @param round number from 1 to the number of rounds in the season, and defaults
#' to most recent. Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
#' @return A tibble with columns driver_id, constructor_id, points awarded, finishing position,
#' grid position, laps completed, race status (finished or otherwise), gap to
#' first place, fastest lap's lap number, fastest lap time, fastest lap in seconds,
#' or NULL if no sprint exists for this season/round combo. Results are paginated
#' automatically, so sprints with more than 100 results are returned in full. Note that
#' `points`, `position`, `grid`, and `laps` are returned by the API as strings and are
#' therefore all **character** columns, not numeric.
load_sprint <- function(season = get_current_season(), round = "last") {
  check_season_arg(season, 2021)
  check_round_arg(round)

  url <- glue::glue(
    "{season}/{round}/sprint.json",
    season = season,
    round = round
  )

  lim <- 100
  data <- get_jolpica_content(url, parameters = list(limit = lim))

  if (is.null(data)) {
    return(NULL)
  }

  if (length(data$MRData$RaceTable$Races) == 0) {
    cli::cli_alert_warning(glue::glue(
      "No Sprint data for season = {season}, round = {round}",
      season = season,
      round = round
    ))
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$RaceTable$Races$SprintResults[[1]]

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

    if (length(data$MRData$RaceTable$Races) == 0) {
      break
    }

    full <- dplyr::bind_rows(
      full,
      data$MRData$RaceTable$Races$SprintResults[[1]]
    )
  }

  data <- full

  data <- data %>%
    tidyr::unnest(
      cols = c("Driver", "Constructor", "Time", "FastestLap"),
      names_repair = "universal",
      names_sep = "."
    ) %>%
    tidyr::unnest(
      cols = c("FastestLap.Time"),
      names_repair = "universal",
      names_sep = "."
    ) %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    dplyr::select(
      "driverId" = "Driver.driverId",
      "constructorId" = "Constructor.constructorId",
      "points",
      "position",
      "grid",
      "laps",
      "status",
      "gap" = "Time.time",
      "lap" = "FastestLap.lap",
      "fastest" = "FastestLap.Time.time"
    ) %>%
    dplyr::mutate(time_sec = time_to_sec(.data$fastest)) %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
}
