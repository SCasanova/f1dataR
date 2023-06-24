#' Load Schedule
#'
#' Loads schedule information for a given F1 season. Use `.load_schedule()` for an uncached version.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @importFrom magrittr "%>%"
#' @keywords internal
#' @return A tibble with one row per circuit in season
.load_schedule <- function(season = get_current_season()){
  if(season != 'current' & (season < 1950 | season > get_current_season())){
    cli::cli_abort('{.var season} must be between 1950 and {get_current_season()} (or use "current")')
    # stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
    #                 current = get_current_season()))
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

#' @inherit .load_schedule title description params return
#' @export
#' @examples
#' # Load this year's schedule:
#' load_schedule()
#'
#' # Load the schedule from 2007
#' load_schedule(2007)
load_schedule <- memoise::memoise(.load_schedule)

