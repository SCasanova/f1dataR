#' Load Qualifying Results
#'
#' Loads qualifying session results for a given season and round. Use `.load_quali()` for an uncached version.
#'
#' @param season number from 2003 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.  Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @keywords internal
#' @return A tibble with one row per driver
.load_quali <- function(season = get_current_season(), round = 'last') {
   if (season != 'current' && (season < 2003 || season > get_current_season())) {
     cli::cli_abort('{.var season} must be between 2003 and {get_current_season()} (or use "current")')
   }

  url <- glue::glue('{season}/{round}/qualifying.json?limit=40',
                    season = season, round = round)
  data <- get_ergast_content(url)
  data <- data$MRData$RaceTable$Races$QualifyingResults[[1]]

  if (season < 2006) {
    data %>%
      tidyr::unnest(cols = c("Driver")) %>%
      dplyr::select("driverId", "position", "Q1") %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::mutate(Q1_sec = time_to_sec(.data$Q1)) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else {
    if (season == 2015 && round == 16) {
      data$Q3 <- NA
    }
    data %>%
      tidyr::unnest(cols = c("Driver")) %>%
      dplyr::select("driverId", "position", "Q1":"Q3") %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::mutate(Q1_sec = time_to_sec(.data$Q1),
                    Q2_sec = time_to_sec(.data$Q2),
                    Q3_sec = time_to_sec(.data$Q3)) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }

}

#' @inherit .load_quali title description params return
#' @export
#' @examples
#' # Load quali from the first race of 2023:
#' load_quali(2023, 1)
#'
#' # Load quali from the third race of 2004:
#' load_quali(2004, 1)
load_quali <- memoise::memoise(.load_quali)
