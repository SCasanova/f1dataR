#' Load Qualifying Results
#'
#' @description Loads qualifying session results for a given season and round.
#' Use `.load_quali()` for an uncached version.
#'
#' @param season number from 2003 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.  Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
#' @return A tibble with one row per driver
load_quali <- function(season = get_current_season(), round = "last") {
  if (season != "current" && (season < 2003 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 2003 and {get_current_season()} (or use "current")')
  }

  url <- glue::glue("{season}/{round}/qualifying.json?limit=40",
    season = season, round = round
  )

  data <- get_ergast_content(url)

  if (is.null(data)) {
    return(NULL)
  }

  data <- data$MRData$RaceTable$Races$QualifyingResults[[1]]

  data<-add_col_if_absent(data, "Q2", NA_character_)
  data<-add_col_if_absent(data, "Q3", NA_character_)

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

  if (season < 2006) {
    return(data %>% dplyr::select(-c("q2", "q3", "q2_sec", "q3_sec")))
  } else {
    return(data)
  }
}
