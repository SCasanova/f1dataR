#' Load Circuit Information
#'
#' @description Loads circuit details for a specific race session. Note that different track layouts are used at some
#' circuits depending on the year of the race.
#'
#' Useful for visualizing or annotating data. Contains information on corners, marshal_lights and marshal_sectors.
#'
#' Each set of these track marker types is returned as a tibble.
#'
#' Also returns an angle (in degrees) to indicate the amount of rotation of the telemetry to visually align the two.
#'
#' More information on the data provided (and uses) can be seen at https://docs.fastf1.dev/circuit_info.html#fastf1.mvapi.CircuitInfo.corners
#'
#' Note that this is an exposition of FastF1 data. As such, caching is recommended (and default behavior).
#' Cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' default is the current working directory.
#'
#' If you have trouble with errors mentioning 'fastf1' or 'get_fastf1_version()' read the
#' 'Setup FastF1 Connection vignette (run \code{vignette('setup_fastf1', 'f1dataR')}).
#'
#' @param season number from 2018 to current season. Defaults to current season.
#' @param round number from 1 to 23 (depending on season selected). Also accepts race name.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' `'DEBUG'`, `'INFO'`, `'WARNING'`, `'ERROR'` and `'CRITICAL'`. See
#' \href{https://docs.fastf1.dev/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @import reticulate
#' @return A list of tibbles containing corner number, marshall post number, or marshall segment, plus a numeric value for
#' rotational offset of the data compared to telemetry data.
#'
#' The tibbles all have the following structure:
#' `x` and `y` specify the position on the track map
#' `number` is the number of the corner. Letter is optionally used to differentiate corners with the same number on some circuits, e.g. “2A”.
#' `angle` is an angle in degrees, used to visually offset the marker’s placement on a track map in a logical direction (usually orthogonal to the track).
#' `distance` is the location of the marker as a distance from the start/finish line.
#'
#' @export
load_circuit_details <- function(season = get_current_season(), round = 1, log_level = "WARNING") {
  # Deprecation Checks
  check_ff1_version()

  # Function Code
  load_race_session(obj_name = "session", season = season, round = round, session = "R", log_level = log_level)

  tryCatch(
    {
      # Only returns a value if session.load() has been successful
      # If it hasn't, retry
      reticulate::py_run_string("session.t0_date")
    },
    error = function(e) {
      reticulate::py_run_string("session.load()")
    }
  )

  py_env <- reticulate::py_run_string("circuit_info = session.get_circuit_info()")

  circuit_info <- reticulate::py_to_r(reticulate::py_get_item(py_env, "circuit_info"))

  corners <- circuit_info$corners %>%
    tibble::tibble() %>%
    janitor::clean_names()

  marshal_post <- circuit_info$marshal_lights %>%
    tibble::tibble() %>%
    janitor::clean_names()

  marshal_sectors <- circuit_info$marshal_sectors %>%
    tibble::tibble() %>%
    janitor::clean_names()

  rotation <- circuit_info$rotation

  return(list(corners, marshal_post, marshal_sectors, rotation))
}
