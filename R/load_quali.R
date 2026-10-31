#' Load Qualifying Results
#'
#' @description Loads qualifying session results for a given season and round.
#'
#' @param season number from 2003 to current season (or the word 'current') (defaults to current season).
#' @param round number from 1 to the number of rounds in the season, and defaults
#' to most recent.  Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
#' @return A tibble with one row per driver, with columns driver_id, position, q1, q2, q3,
#' q1_sec, q2_sec, q3_sec (lap times as strings and in seconds for each qualifying segment),
#' or NULL if the request fails. For seasons before 2006 (when qualifying had only one segment),
#' the q2, q3, q2_sec, and q3_sec columns are dropped. Results are paginated automatically,
#' so sessions with more than 100 results are returned in full. Note that `position` is
#' returned by the API as a string and is therefore a **character** column, not numeric.
load_quali <- function(season = get_current_season(), round = "last") {
  season_num <- check_season_arg(season, 2003)
  check_round_arg(round)

  url <- glue::glue(
    "{season}/{round}/qualifying.json",
    season = season,
    round = round
  )

  lim <- 100
  data <- get_jolpica_content(url, parameters = list(limit = lim))

  if (is.null(data)) {
    return(NULL)
  }

  if (length(data$MRData$RaceTable$Races$QualifyingResults) == 0) {
    cli::cli_alert_warning(
      "No qualifying data available for this season/round."
    )
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$RaceTable$Races$QualifyingResults[[1]]

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

    if (length(data$MRData$RaceTable$Races$QualifyingResults) == 0) {
      break
    }

    full <- dplyr::bind_rows(
      full,
      data$MRData$RaceTable$Races$QualifyingResults[[1]]
    )
  }

  data <- full

  data <- add_col_if_absent(data, "Q2", NA_character_)
  data <- add_col_if_absent(data, "Q3", NA_character_)

  data <- data %>%
    tidyr::unnest(cols = c("Driver")) %>%
    dplyr::select("driverId", "position", "Q1", "Q2", "Q3") %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    dplyr::mutate(
      Q1_sec = time_to_sec(.data$Q1),
      Q2_sec = time_to_sec(.data$Q2),
      Q3_sec = time_to_sec(.data$Q3)
    ) %>%
    tibble::as_tibble() %>%
    janitor::clean_names()

  if (season_num < 2006) {
    return(data %>% dplyr::select(-c("q2", "q3", "q2_sec", "q3_sec")))
  } else {
    return(data)
  }
}
