#' Load Schedule
#'
#' @description Loads schedule information for a given F1 season.
#'
#' @param season number from 1950 to current season (defaults to current season). `'current'` also accepted.
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with one row per round in season. Indicates in sprint_date if a specific round has a sprint race.
#' Returns `NULL` on API failure.
load_schedule <- function(season = get_current_season()) {
  check_season_arg(season, 1950)

  url <- glue::glue("{season}.json", season = season)

  lim <- 100
  data <- get_jolpica_content(url, parameters = list(limit = lim))
  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$RaceTable$Races

  # Iterate over the request until completed
  while (nrow(full) < total) {
    offset <- offset + lim

    data <- get_jolpica_content(
      url,
      parameters = list(limit = lim, offset = offset)
    )

    if (is.null(data)) {
      return(NULL)
    }

    full <- dplyr::bind_rows(full, data$MRData$RaceTable$Races)
  }

  data <- full

  if ("url" %in% colnames(data)) {
    data$url <- NULL
  }

  if ("Circuit" %in% colnames(data)) {
    if (inherits(data$Circuit, "data.frame")) {
      data <- data %>%
        tidyr::unnest(cols = c("Circuit"), names_repair = "universal")
    }
  }

  if ("Location" %in% colnames(data)) {
    if (inherits(data$Location, "data.frame")) {
      data <- data %>%
        tidyr::unnest(cols = c("Location"), names_repair = "universal")
    }
  }

  if ("Sprint" %in% colnames(data)) {
    if (inherits(data$Sprint, "data.frame")) {
      data <- data %>%
        tidyr::unnest(cols = c("Sprint"), names_sep = "_")
    }
  }

  data <- add_col_if_absent(data, "time", NA_character_)
  data <- add_col_if_absent(data, "sprint_date", NA_character_)

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
