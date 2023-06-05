#' Load Pitstop Data (not cached)
#'
#' Loads pit stop info (number, lap, time elapsed) for a given race
#' in a season. Pit stop data is available from 2012 onward.
#' This function does not export, only the cached version.
#'
#' @param season number from 2011 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season selected) and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @return A tibble with columns driverId, lap, stop (number), time (of day),
#' and stop duration

.load_pitstops <- function(season = 'current', round  ='last'){
  if(season != 'current' & (season < 2011 | season > get_current_season())){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
                    current=get_current_season()))
  }

  url <- glue::glue('http://ergast.com/api/f1/{season}/{round}/pitstops.json?limit=80',
                    season = season, round = round)
  data <- get_ergast_content(url)
  data$MRData$RaceTable$Races$PitStops[[1]] %>% +
    tibble::as_tibble()
}

#' Load Pitstop Data
#'
#' Loads pit stop info (number, lap, time elapsed) for a given race
#' in a season. Pit stop data is available from 2012 onward.
#'
#' @param season number from 2012 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season selected) and defaults
#' to most recent.
#' @return A tibble with columns driverId, lap, stop (number), time (of day),
#' and stop duration
#' @export

load_pitstops <- memoise::memoise(.load_pitstops)
