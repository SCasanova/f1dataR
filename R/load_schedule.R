#' Load Schedule (not cached)
#'
#' Loads schedule information for a given F1 season.
#' This function does not export, only the cached version.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @importFrom magrittr "%>%"
#' @keyword internal
#' @return A tibble with one row per circuit in season

.load_schedule <- function(season = 'current'){
  if(season != 'current' & (season < 1950 | season > get_current_season())){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
                    current = get_current_season()))
  }

  url <- glue::glue('{season}.json?limit=30', season = season)
  data <- get_ergast_content(url)

  if(season < 2005){
    data$MRData$RaceTable$Races %>%
      tidyr::unnest(cols = c("Circuit"), names_repair = 'universal') %>%
      janitor::clean_names() %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      tidyr::unnest(cols = c("location")) %>%
      dplyr::select("season",
                    "round",
                    "race_name",
                    "circuit_id",
                    "circuit_name",
                    "lat":"country",
                    "date") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else{
    data$MRData$RaceTable$Races %>%
      tidyr::unnest(cols = c("Circuit"), names_repair = 'universal') %>%
      janitor::clean_names() %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      tidyr::unnest(cols = c("location")) %>%
      dplyr::select("season",
                    "round",
                    "race_name",
                    "circuit_id",
                    "circuit_name",
                    "lat":"country",
                    "date",
                    "time") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
   }

}

#' Load Schedule
#'
#' Loads schedule information for a given F1 season.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @return A tibble with one row per circuit in season
#' @export

load_schedule <- memoise::memoise(.load_schedule)

