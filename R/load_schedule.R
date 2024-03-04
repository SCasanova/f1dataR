#' Load Schedule
#'
#' @description Loads schedule information for a given F1 season.
#' Use `.load_schedule()` for an uncached version.
#'
#' @param season number from 1950 to current season (defaults to current season). `'current'` also accepted.
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with one row per round in season. Indicates in sprint_date if a specific round has a sprint race
load_schedule <- function(season = get_current_season()) {
  if (season != "current" && (season < 1950 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 1950 and {get_current_season()} (or use "current")')
  }

  url <- glue::glue("{season}.json?limit=30", season = season)

  data <- get_ergast_content(url)
  if (is.null(data)) {
    return(NULL)
  }

  data <- data$MRData$RaceTable$Races %>%
    dplyr::select(-"url")

  if ("Circuit" %in% colnames(data)) {
    if (class(data$Circuit) == "data.frame") {
      data <- data %>%
        tidyr::unnest(cols = c("Circuit"), names_repair = "universal")
    }
  }

  if ("Location" %in% colnames(data)) {
    if (class(data$Location) == "data.frame") {
      data <- data %>%
        tidyr::unnest(cols = c("Location"), names_repair = "universal")
    }
  }

  if ("Sprint" %in% colnames(data)) {
    if (class(data$Sprint) == "data.frame") {
      data <- data %>%
        tidyr::unnest(cols = c("Sprint"), names_sep = "_")
    }
  }

  if (!("time" %in% colnames(data))) {
    data <- data %>%
      dplyr::mutate("time" = NA_character_)
  }

  if (!("sprint_date" %in% colnames(data))) {
    data <- data %>%
      dplyr::mutate("sprint_date" = NA_character_)
  }

  data <- data %>%
    janitor::clean_names() %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    dplyr::select(
      "season",
      "round",
      "race_name",
      "circuit_id",
      "circuit_name",
      "lat",
      "long",
      "locality",
      "country",
      "date",
      "time",
      "sprint_date"
    ) %>%
    tibble::as_tibble() %>%
    janitor::clean_names()

  return(data)
}
