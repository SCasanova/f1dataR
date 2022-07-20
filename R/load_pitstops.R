#' Load Pitstop Data (not cached)
#'
#' Loads pit stop info (number, lap, time elapsed) for a given race
#' in a season. Pit stop data is available from 2012 onwards.
#' This funtion does not export, only the cached version.
#'
#' @param season number from 2011 to 2022 (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId, lap, stop (number), time (of day),
#' and stop duration

.load_pitstops <- function(season = 'current', race  ='last'){
  if(season != 'current' & (season < 2011 | season > 2022)){
    stop('Year must be between 1950 and 2022 (or use "current")')
  }
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
#' @export

load_pitstops <- memoise::memoise(.load_pitstops)
