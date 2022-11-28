#' Load Schedule (not cached)
#'
#' Loads schedule information for a given F1 season.
#' This funtion does not export, only the cached version.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @return A dataframe with columns season, round, circuitId, circuitName,
#' latitute and Longitude, locality (city usually), country, date, and time
#' of the race.

.load_schedule <- function(season = 'current'){
  if(season != 'current' & (season < 1950 | season > as.numeric(strftime(Sys.Date(), "%Y")))){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")', current = as.numeric(strftime(Sys.Date(), "%Y"))))
  } else if(season < 2005){
    res <-
      httr::GET(glue::glue('http://ergast.com/api/f1/{season}.json?limit=30', season = season))
    data <- jsonlite::fromJSON(rawToChar(res$content))
    data$MRData$RaceTable$Races %>%
      tidyr::unnest(cols = c(.data$Circuit), names_repair = 'universal') %>%
      janitor::clean_names() %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      tidyr::unnest(cols = c(.data$location)) %>%
      dplyr::select(.data$season,
                    .data$round,
                    .data$race_name,
                    .data$circuit_id,
                    .data$circuit_name,
                    .data$lat:.data$country,
                    .data$date) %>%
      tibble::as_tibble()
  } else{
    res <-  httr::GET(glue::glue('http://ergast.com/api/f1/{season}.json?limit=30', season = season))
    data <- jsonlite::fromJSON(rawToChar(res$content))
    data$MRData$RaceTable$Races %>%
      tidyr::unnest(cols = c(.data$Circuit), names_repair = 'universal') %>%
      janitor::clean_names() %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      tidyr::unnest(cols = c(.data$location)) %>%
      dplyr::select(.data$season,
                    .data$round,
                    .data$race_name,
                    .data$circuit_id,
                    .data$circuit_name,
                    .data$lat:.data$country,
                    .data$date,
                    .data$time) %>%
      tibble::as_tibble()
   }

}

#' Load Schedule
#'
#' Loads schedule information for a given F1 season.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @return A dataframe with columns season, round, circuitId, circuitName,
#' latitute and Longitude, locality (city usually), country, date, and time
#' of the race.
#' @export

load_schedule <- memoise::memoise(.load_schedule)

