#' Load Sprint Results (not cached)
#'
#' Loads final race results for a given year and round. Note not all rounds have
#' sprint results
#'
#' @param season number from 1950 to current season  (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @return A dataframe with columns driverId, points awarded, finishing position,
#' grid position, laps completed, race status (finished or otherwise), gap to
#' first place, fastest lap, fastest lap time, fastest lap in seconds,
#' or NULL if no sprint exists for this season/round combo

.load_sprint <- function(season = 'current', round = 'last'){
  if(season != 'current' & (season < 2021 | season > get_current_season())){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
                    current = get_current_season()))
  }

  url <- glue::glue('http://ergast.com/api/f1/{season}/{round}/sprint.json?limit=40',
                    season = season, round = round)
  data <- get_ergast_content(url)

  if(length(data$MRData$RaceTable$Races) == 0){
    message(glue::glue("No Sprint data for season = {season}, round = {round}",
                       season = season, round = round))
    return(NULL)
  }

  data$MRData$RaceTable$Races$SprintResults[[1]] %>%
    tidyr::unnest(cols = c("Driver", "Time", "FastestLap"),
                  names_repair = 'universal') %>%
    tidyr::unnest(cols = c("Time"),
                  names_repair = 'universal') %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    dplyr::select(
      "driverId",
      "points",
      "position",
      "grid",
      "laps",
      "status",
      "position",
      gap = "time...18",
      "lap",
      fastest = "time...20"
    ) %>%
    dplyr::mutate(time_sec = time_to_sec(.data$fastest)) %>%
    tibble::as_tibble()

}

#' Load Sprint
#'
#' @description Loads sprint race results for a given year and round. Note not
#' all rounds have sprint results
#'
#' @param season number from 2021 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @return A dataframe with columns driverId, points awarded, finishing position,
#' grid position, laps completed, race status (finished or otherwise), gap to
#' first place, fastest lap, fastest lap time, fastest lap in seconds,
#' or NULL if no sprint exists for this season/round combo
#' @export

load_sprint <- memoise::memoise(.load_sprint)

