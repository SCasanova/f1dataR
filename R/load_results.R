#' Load Results (not cached)
#'
#' Loads final race resuts for a given year and round.
#'
#' @param season number from 1950 to current season  (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId, grid position, laps completed,
#' race status (finished or otherwise), gap to first place, fastest lap rank,
#' fastest lap time, fastest lap in seconds, and top speed in kph.

.load_results <- function(season = 'current', round = 'last'){
  if(season != 'current' & (season < 1950 | season > as.numeric(strftime(Sys.Date(), "%Y")))){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")', current = as.numeric(strftime(Sys.Date(), "%Y"))))
  }
  if(season < 2004){
    res <-  httr::GET(glue::glue(
      'http://ergast.com/api/f1/{season}/{round}/results.json?limit=40',
      season = season,
      round = round
    ))
    data <- jsonlite::fromJSON(rawToChar(res$content))
    data$MRData$RaceTable$Races$Results[[1]] %>%
      tidyr::unnest(cols = c(Driver, Time)) %>%
      dplyr::select(driverId, position, points, grid:time) %>%
    tibble::as_tibble()
  } else{
    res <-  httr::GET(glue::glue('http://ergast.com/api/f1/{season}/{round}/results.json?limit=40', season = season, round = round))
    data <- jsonlite::fromJSON(rawToChar(res$content))
    data$MRData$RaceTable$Races$Results[[1]] %>%
      tidyr::unnest(cols = c(Driver, Time, FastestLap)) %>%
      dplyr::select(driverId, points,position, grid:AverageSpeed) %>%
      tidyr::unnest(cols = c(Time, AverageSpeed),
                    names_repair = 'universal') %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select(
        driverId:status,
        gap = `time...8`,
        fastest_rank =  rank,
        laps,
        fastest = `time...11`,
        top_speed_kph = speed
      ) %>%
      dplyr::mutate(time_sec = time_to_sec(fastest)) %>%
      tibble::as_tibble()
  }

}

#' Load Results
#'
#' Loads final race resuts for a given year and round.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @return A dataframe with columns driverId, grid position, laps completed,
#' race status (finished or otherwise), gap to first place, fastest lap rank,
#' fastest lap time, fastest lap in seconds, and top speed in kph.
#' @export

load_results <- ifelse(requireNamespace('memoise', quietly = T), memoise::memoise(.load_results), .load_results)

