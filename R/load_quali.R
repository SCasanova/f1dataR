#' Load Qualifying Results (not cached)
#'
#' Loads qualifying session results for a given season and round.
#'
#' @param season number from 1950 to 2022 (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId, obtained position, Q1, Q2, and Q3
#' times in clock format as well as seconds.

.load_quali <- function(season = 'current', round = 'last'){
   if(season != 'current' & (season < 2003 | season > 2022)){
    stop('Year must be between 1950 and 2022 (or use "current")')
   }
  if(season <2006){
    res <-
      httr::GET(
        glue::glue(
          'http://ergast.com/api/f1/{season}/{round}/qualifying.json?limit=40',
          season = season,
          round = round
        )
      )
    data <- jsonlite::fromJSON(rawToChar(res$content))
    data$MRData$RaceTable$Races$QualifyingResults[[1]] %>%
      tidyr::unnest(cols = c(Driver)) %>%
      dplyr::select(driverId, position, Q1:Q3) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::mutate(Q1_sec = time_to_sec(Q1)) %>%
      tibble::as_tibble()
  } else{
    res <-
      httr::GET(
        glue::glue(
          'http://ergast.com/api/f1/{season}/{round}/qualifying.json?limit=40',
          season = season,
          round = round
        )
      )
    data <- jsonlite::fromJSON(rawToChar(res$content))
    data$MRData$RaceTable$Races$QualifyingResults[[1]] %>%
      tidyr::unnest(cols = c(Driver)) %>%
      dplyr::select(driverId, position, Q1:Q3) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::mutate(Q1_sec = time_to_sec(Q1),
                    Q2_sec = time_to_sec(Q2),
                    Q3_sec = time_to_sec(Q3)) %>%
      tibble::as_tibble()
  }

}

#' Load Qualifying Results
#'
#' Loads qualifying session results for a given season and round.
#'
#' @param season number from 1950 to 2022 (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId, obtained position, Q1, Q2, and Q3
#' times in clock format as well as seconds.
#' @export

load_quali <- memoise::memoise(.load_quali)

