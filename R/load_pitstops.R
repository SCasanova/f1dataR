#' Load Pitstop Data (not cached)
#'
#' Loads pit stop info (number, lap, time elapsed) for a given race
#' in a season. Pit stop data is available from 2012 onwards.
#' This funtion does not export, only the cached version.
#'
#' @param season number from 2012 to 2022 (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId, lap, stop (number), time (of day),
#' and stop duration
#' @export

.load_pitstops <- function(season = 'current', race  ='last'){
  res <-  httr::GET(glue::glue('http://ergast.com/api/f1/{season}/{race}/pitstops.json?limit=80',
                               season = season,
                               race = race))
  data <- jsonlite::fromJSON(rawToChar(res$content))
  data$MRData$RaceTable$Races$PitStops[[1]] %>% tibble::as_tibble()
}

#' Load Pitstop Data
#'
#' Loads pit stop info (number, lap, time elapsed) for a given race
#' in a season. Pit stop data is available from 2012 onwards.
#'
#' @param season number from 2012 to 2022 (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent.
#' @return A dataframe with columns

load_pitstops <- memoise::memoise(.load_pitstops)
