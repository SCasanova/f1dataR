#' Load Lap by Lap Time Data (not cached)
#'
#' This function loads lap-by-lap time data for all drivers in a given season
#' and round. This funtion does not export, only the cached version.
#'
#' @param season number from 1950 to 2022 (defaults to current season)
#' @param race number from 1 to 22 (depending on season selected) and defaults
#' to most recent
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId (unique and recurring), position
#' during lap, time (in clock form), lap number, time (in seconds), and season.

.load_laps <- function(season = 'current', race = 'last'){
  res <-  httr::GET(glue::glue('http://ergast.com/api/f1/{season}/{race}/laps.json?limit=1000',
                    season = season,
                    race = race))
  data <- jsonlite::fromJSON(rawToChar(res$content))
  total <- data$MRData$total %>% as.numeric()
  if(total-1000 >0 & total-1000 <= 1000 ){
    lim <- total-1000
    res2 <- httr::GET(glue::glue('http://ergast.com/api/f1/current/last/laps.json?limit={lim}&offset=1000', lim = lim))
    data2 <- jsonlite::fromJSON(rawToChar(res2$content))

  full <- dplyr::bind_rows(data$MRData$RaceTable$Races$Laps[[1]][2], data2$MRData$RaceTable$Races$Laps[[1]][2])
  } else{
    full <- data$MRData$RaceTable$Races$Laps[[1]][2]
  }
  laps <- tibble::tibble()
  for (i in 1:nrow(full)) {
    laps <- dplyr::bind_rows(laps,
                      full[[1]][i][[1]] %>%
                        dplyr::mutate(lap = i,
                               time_sec = purrr::map_dbl(time, time_to_sec),
                               season = season))
  }
  laps
}

#' Convert Clock time to seconds
#'
#' This function converts clock format time (0:00.000) to seconds (0.000s)
#'
#' @param time character string with clock format (0:00.000)
#' @importFrom magrittr "%>%"
#' @return A numeric variable that represents that time in seconds

time_to_sec <- function(time){
  split <- time %>% stringr::str_split(':')
  as.numeric(split[[1]][1])*60 + as.numeric(split[[1]][2])
}

#' Load Lap by Lap Time Data
#'
#' This function loads lap-by-lap time data for all drivers in a given season
#' and round.
#'
#' @param season number from 1950 to 2022 (defaults to current season)
#' @param race number from 1 to 22 (depending on season selected) and defaults
#' to most recent
#' @return A dataframe with columns driverId (unique and recurring), position
#' during lap, time (in clock form), lap number, time (in seconds), and season.
#' @export

load_laps <- memoise::memoise(.load_laps)
