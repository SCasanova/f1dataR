#' Load Schedule (not cached)
#'
#' Loads schedule information for a given F1 season.
#' This funtion does not export, only the cached version.
#'
#' @param season number from 1950 to 2022 (defaults to current season).
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns season, round, circuitId, circuitName,
#' latitute and Longitude, locality (city usually), country, date, and time
#' of the race.

.load_schedule <- function(season = 2022){
  res <-  httr::GET(glue::glue('http://ergast.com/api/f1/{season}.json?limit=30', season = season))
  data <- jsonlite::fromJSON(rawToChar(res$content))
  data$MRData$RaceTable$Races %>%
    tidyr::unnest(cols = c(Circuit), names_repair = 'universal') %>%
    janitor::clean_names() %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    tidyr::unnest(cols = c(location)) %>%
    dplyr::select(
      season,
      round,
      race_name,
      circuit_id,
      circuit_name,
      lat:country,
      date, time
    )
}

#' Load Schedule
#'
#' Loads schedule information for a given F1 season.
#'
#' @param season number from 1950 to 2022 (defaults to current season).
#' @return A dataframe with columns season, round, circuitId, circuitName,
#' latitute and Longitude, locality (city usually), country, date, and time
#' of the race.
#' @export

load_schedule <- memoise::memoise(.load_schedule)

