#' Load Lap by Lap Time Data (not cached)
#'
#' Loads lap-by-lap time data for all drivers in a given season
#' and round. Lap time data is available from 1996 onward. This function does not export, only the cached version.
#'
#' @param season number from 1996 to current season (defaults to current season)
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId (unique and recurring), position
#' during lap, time (in clock form), lap number, time (in seconds), and season.


.load_laps <- function(season = 'current', race = 'last'){
  if(season != 'current' & (season < 1996 | season > as.numeric(strftime(Sys.Date(), "%Y")))){
    stop(glue::glue('Year must be between 1996 and {current} (or use "current")', current=as.numeric(strftime(Sys.Date(), "%Y"))))
  }
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
  season_text <-  ifelse(season == 'current', as.numeric(strftime(Sys.Date(), "%Y")), season)
  for (i in 1:nrow(full)) {
    laps <- dplyr::bind_rows(laps,
                      full[[1]][i][[1]] %>%
                        dplyr::mutate(lap = i,
                               time_sec = time_to_sec(.data$time),
                               season = season_text))
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
  subfun <- function(x){
    if(is.na(x))
      NA
    else{
      split <- x %>% stringr::str_split(':')
      as.numeric(split[[1]][1])*60 + as.numeric(split[[1]][2])
    }
  }
  purrr::map_dbl(time, subfun)

}

#' Load Lap by Lap Time Data
#'
#' Loads lap-by-lap time data for all drivers in a given season
#' and round. Lap time data is available from 1996 onward.
#'
#' @param season number from 1996 to current season (defaults to current season)
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent
#' @return A dataframe with columns driverId (unique and recurring), position
#' during lap, time (in clock form), lap number, time (in seconds), and season.
#' @export

load_laps <- memoise::memoise(.load_laps)
