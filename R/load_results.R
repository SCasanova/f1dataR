#' Load Results
#'
#' @description Loads final race results for a given year and round. Use `.load_results()` for an uncached version
#'
#' @param season number from 1950 to current season (or the word 'current') (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults to most recent. Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
#' @return A tibble with one row per driver, with columns for driver & constructor ID, the points won by each driver in
#'   the race, their finishing position, their starting (grid) position, number of completed laps, status code, gap to
#'   leader (or time of race), fastest lap ranking, drivers' fastest lap time, top speed achieved, and fastest lap time
#'   in seconds.
load_results <- function(season = get_current_season(), round = "last") {
  if (season != "current" && (season < 1950 || season > get_current_season())) {
    cli::cli_abort(
      '{.var season} must be between 1950 and {get_current_season()} (or use "current")'
    )
  }

  url <- glue::glue(
    "{season}/{round}/results.json?limit=40",
    season = season,
    round = round
  )
  data <- get_jolpica_content(url)

  if (is.null(data)) {
    return(NULL)
  }

  data <- data$MRData$RaceTable$Races$Results[[1]]

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
        top_speed_kph = "FastestLap.AverageSpeed.speed",
      ) %>%
      dplyr::mutate(time_sec = time_to_sec(.data$fastest)) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }
}
