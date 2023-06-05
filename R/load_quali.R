#' Load Qualifying Results (not cached)
#'
#' Loads qualifying session results for a given season and round.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @return A tibble with one row per driver.

.load_quali <- function(season = 'current', round = 'last'){
   if(season != 'current' & (season < 2003 | season > get_current_season())){
    stop(glue::glue('Year must be between 2003 and {current} (or use "current")',
                    current=get_current_season()))
   }

  url <- glue::glue('http://ergast.com/api/f1/{season}/{round}/qualifying.json?limit=40',
                    season = season, round = round)
  data <- get_ergast_content(url)

  if(season < 2006){
    data$MRData$RaceTable$Races$QualifyingResults[[1]] %>%
      tidyr::unnest(cols = c("Driver")) %>%
      dplyr::select("driverId", "position", "Q1") %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::mutate(Q1_sec = time_to_sec(.data$Q1)) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else{
    data$MRData$RaceTable$Races$QualifyingResults[[1]] %>%
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

#' Load Qualifying Results
#'
#' Loads qualifying session results for a given season and round.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @return A tibble with one row per driver.
#' @export

load_quali <- memoise::memoise(.load_quali)

