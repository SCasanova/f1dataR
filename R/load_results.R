#' Load Results
#'
#' Loads final race results for a given year and round. Use `.load_results()` for an uncached version
#'
#' @param season number from 1950 to current season (or the word 'current') (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent. Also accepts `'last'`.
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @keywords internal
#' @return A tibble with one row per driver
.load_results <- function(season = get_current_season(), round = "last") {
  if (season != "current" && (season < 1950 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 1950 and {get_current_season()} (or use "current")')
  }

  url <- glue::glue("{season}/{round}/results.json?limit=40",
                    season = season, round = round)
  data <- get_ergast_content(url)

  data <- data$MRData$RaceTable$Races$Results[[1]]

  if (!("FastestLap" %in% colnames(data))) {
    # all races from before 2004 will have no 'Fastest Lap' column,
    # but also 2021 round 12 (Belgian GP) where no racing laps were run
    data %>%
      tidyr::unnest(cols = c("Driver", "Time", "Constructor"), names_repair = "universal") %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select("driverId", "constructorId", "position", "points", "grid":"status", gap = "time") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  } else {
    data %>%
      tidyr::unnest(cols = c("Driver", "Constructor", "Time", "FastestLap"), names_repair = "universal") %>%
      dplyr::select("driverId", "points", "position", "grid":"AverageSpeed", "constructorId", "name") %>%
      tidyr::unnest(cols = c("Time", "AverageSpeed"),
                    names_repair = "universal") %>%
      suppressWarnings() %>%
      suppressMessages() %>%
      dplyr::select(
        "driverId",
        "constructorId",
        "points":"status",
        gap = "time...8",
        fastest_rank =  "rank",
        "laps",
        fastest = "time...11",
        top_speed_kph = "speed",
      ) %>%
      dplyr::mutate(time_sec = time_to_sec(.data$fastest)) %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  }
}

#' @inherit .load_results title description params return
#' @export
#' @examples
#' # Load results from the third race of 2023
#' load_results(2023, 3)
#'
#' # Load results from the first race of 1995
#' load_results(1995, 1)
#'
#' # Load results from the last race of 1963
#' load_results(1963, 'last')
#'
load_results <- memoise::memoise(.load_results)
