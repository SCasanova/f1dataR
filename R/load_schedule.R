#' Load Schedule
#'
#' @description Loads schedule information for a given F1 season.
#' Use `.load_schedule()` for an uncached version.
#'
#' @param season number from 1950 to current season (defaults to current season). `'current'` also accepted.
#' @importFrom magrittr "%>%"
#' @keywords internal
#' @return A tibble with one row per round in season. Indicates in sprint_date if a specific round has a sprint race
.load_schedule <- function(season = get_current_season()) {
  if (season != "current" && (season < 1950 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 1950 and {get_current_season()} (or use "current")')
  }

  url <- glue::glue("{season}.json?limit=30", season = season)
  data <- get_ergast_content(url)

  if (season < 2005) {
    data$MRData$RaceTable$Races %>%
      tidyr::unnest(cols = c("Circuit"), names_repair = "universal") %>%
      janitor::clean_names() %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      tidyr::unnest(cols = c("location")) %>%
      dplyr::select(
        "season",
        "round",
        "race_name",
        "circuit_id",
        "circuit_name",
        "lat":"country",
        "date"
      ) %>%
      dplyr::mutate("time" = NA_character_, "sprint_date" = NA_character_) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else if (season < 2021) {
    data$MRData$RaceTable$Races %>%
      tidyr::unnest(cols = c('Circuit'), names_repair = "universal") %>%
      janitor::clean_names() %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      tidyr::unnest(cols = c("location")) %>%
      dplyr::select(
        "season",
        "round",
        "race_name",
        "circuit_id",
        "circuit_name",
        "lat":"country",
        "date",
        "time"
      ) %>%
      dplyr::mutate("sprint_date" = NA_character_) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else {
    data$MRData$RaceTable$Races %>%
      tidyr::unnest(cols = c("Circuit"), names_repair = "universal") %>%
      janitor::clean_names() %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      tidyr::unnest(cols = c("location", "sprint"), names_sep = "_") %>%
      dplyr::select(
        "season",
        "round",
        "race_name",
        "circuit_id",
        "circuit_name",
        "lat" = "location_lat",
        "long" = "location_long",
        "locality" = "location_locality",
        "country" = "location_country",
        "date",
        "time",
        "sprint_date"
      ) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }
}

#' @inherit .load_schedule title description params return
#' @export
#' @examples
#' # Load this year's schedule. Note the weekends which have sprints
#' load_schedule()
#'
#' # Load the schedule from 2008
#' load_schedule(2008)
load_schedule <- memoise::memoise(.load_schedule)
