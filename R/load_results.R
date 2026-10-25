#' Load Results
#'
#' @description Loads final race results for a given year and round.
#'
#' @param season number from 1950 to current season (or the word 'current') (defaults to current season).
#' @param round number from 1 to the number of rounds in the season, and defaults to most recent. Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
#' @return A tibble with one row per driver, with columns for driver & constructor ID, the points won by each driver in
#'   the race, their finishing position, their starting (grid) position, number of completed laps, status code, gap to
#'   leader (or time of race), fastest lap ranking, drivers' fastest lap time, top speed achieved, and fastest lap time
#'   in seconds, or NULL if the request fails. `gap` is a string like `"m:ss.ttt"` giving the gap to the leader, or
#'   the leader's total race time for the race winner. For races without fastest-lap data (races before 2004, and
#'   2021 round 12), `fastest_rank`, `fastest`, `top_speed_kph`, and `time_sec` will be `NA`. Note that `points`,
#'   `position`, `grid`, and `laps` are returned by the API as strings and are therefore all **character** columns,
#'   not numeric, even though they look numeric (e.g. `position` can also be non-numeric text such as `"R"` for a
#'   retirement). Coerce with `as.numeric()` if a numeric type is required.
load_results <- function(season = get_current_season(), round = "last") {
  check_season_arg(season, 1950)
  check_round_arg(round)

  url <- glue::glue(
    "{season}/{round}/results.json",
    season = season,
    round = round
  )
  lim <- 100
  data <- get_jolpica_content(url, parameters = list(limit = lim))

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$RaceTable$Races$Results[[1]]

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

    full <- dplyr::bind_rows(full, data$MRData$RaceTable$Races$Results[[1]])
  }

  data <- full

  if (!("FastestLap" %in% colnames(data))) {
    # all races from before 2004 will have no 'Fastest Lap' column,
    # but also 2021 round 12 (Belgian GP) where no racing laps were run
    data %>%
      tidyr::unnest(
        cols = c("Driver", "Time", "Constructor"),
        names_sep = ".",
        names_repair = "universal"
      ) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select(
        "driverId" = "Driver.driverId",
        "constructorId" = "Constructor.constructorId",
        "points",
        "position",
        "grid",
        "laps",
        "status",
        gap = "Time.time"
      ) %>%
      dplyr::mutate(
        fastest_rank = NA_integer_,
        fastest = NA_character_,
        top_speed_kph = NA_real_,
        time_sec = NA_real_
      ) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else if (!("AverageSpeed" %in% colnames(data$FastestLap))) {
    data %>%
      tidyr::unnest(
        cols = c("Driver", "Constructor", "Time", "FastestLap"),
        names_sep = ".",
        names_repair = "universal"
      ) %>%
      tidyr::unnest(
        cols = "FastestLap.Time",
        names_sep = ".",
        names_repair = "universal"
      ) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::mutate(top_speed_kph = NA_real_) %>%
      dplyr::select(
        "driverId" = "Driver.driverId",
        "constructorId" = "Constructor.constructorId",
        "points",
        "position",
        "grid",
        "laps",
        "status",
        gap = "Time.time",
        fastest_rank = "FastestLap.rank",
        fastest = "FastestLap.Time.time",
        top_speed_kph
      ) %>%
      dplyr::mutate(time_sec = time_to_sec(.data$fastest)) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else {
    data %>%
      tidyr::unnest(
        cols = c("Driver", "Constructor", "Time", "FastestLap"),
        names_sep = ".",
        names_repair = "universal"
      ) %>%
      tidyr::unnest(
        cols = c("FastestLap.Time", "FastestLap.AverageSpeed"),
        names_sep = ".",
        names_repair = "universal"
      ) %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select(
        "driverId" = "Driver.driverId",
        "constructorId" = "Constructor.constructorId",
        "points",
        "position",
        "grid",
        "laps",
        "status",
        gap = "Time.time",
        fastest_rank = "FastestLap.rank",
        fastest = "FastestLap.Time.time",
        top_speed_kph = "FastestLap.AverageSpeed.speed"
      ) %>%
      dplyr::mutate(time_sec = time_to_sec(.data$fastest)) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }
}
