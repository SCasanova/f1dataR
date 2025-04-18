#' Load Telemetry Data for a Driver
#'
#' @description Receives season, race number, driver code, and an optional fastest lap only
#' argument to output car telemetry for the selected situation.
#' Example usage of this code can be seen in the Introduction vignette (run
#' \code{vignette('introduction', 'f1dataR')} to read). Multiple drivers' telemetry can be appended
#' to one data frame by the user.
#'
#' If you have trouble with errors mentioning 'fastf1' or 'get_fastf1_version()' read the
#' "Setup FastF1 Connection" vignette (run \code{vignette('setup_fastf1', 'f1dataR')}).
#'
#' @param season number from 2018 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season selected). Also accepts race name.
#' @param session the code for the session to load Options are `'FP1'`, `'FP2'`, `'FP3'`,
#' `'Q'`, `'S'`, `'SS'`, `'SQ'`, and `'R'`. Default is `'R'`, which refers to Race.
#' @param driver three letter driver code (see `load_drivers()` for a list)
#' @param laps which lap's telemetry to return. One of an integer lap number (<= total laps in the race), `fastest`,
#' or `all`. Note that integer lap choice requires `fastf1` version 3.0 or greater.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' `'DEBUG'`, `'INFO'`, `'WARNING'`, `'ERROR'` and `'CRITICAL'`. See \href{https://docs.fastf1.dev/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, use `round`.
#' @param fastest_only `r lifecycle::badge("deprecated")` `fastest_only` is no longer supported, indicated preferred
#' laps in `laps`.
#' @importFrom magrittr "%>%"
#' @return A tibble with telemetry data for selected driver/session.
#' @import reticulate
#' @export
#' @examples
#' if (interactive()) {
#'   telem <- load_driver_telemetry(
#'     season = 2023,
#'     round = "Bahrain",
#'     session = "Q",
#'     driver = "HAM",
#'     laps = "fastest"
#'   )
#' }
#'
load_driver_telemetry <- function(season = get_current_season(), round = 1, session = "R", driver, laps = "fastest",
                                  log_level = "WARNING", race = lifecycle::deprecated(),
                                  fastest_only = lifecycle::deprecated()) {
  # Deprecation Checks
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop("1.4.0", "load_driver_telemetry(race)", "load_driver_telemetry(round)")
  }
  if (lifecycle::is_present(fastest_only)) {
    lifecycle::deprecate_stop("1.4.0", "load_driver_telemetry(fastest_only)", "load_driver_telemetry(laps)")
  }
  check_ff1_version()

  # Function Code
  # Param checks
  if (!(laps %in% c("fastest", "all"))) {
    if (is.numeric(laps)) {
      if (as.numeric(laps) != as.integer(laps)) {
        cli::cli_abort("{.var laps} must be one of `fastest`, `all` or an integer value")
      }
    } else {
      cli::cli_abort("{.var laps} must be one of `fastest`, `all` or an integer value")
    }
  }

  status <- load_race_session(obj_name = "session", season = season, round = round, session = session, log_level = log_level)

  if (is.null(status)) {
    # Failure to load - escape
    return(NULL)
  }

  if (laps == "fastest") {
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_drivers('{driver}').pick_fastest().get_telemetry().add_distance().add_driver_ahead()",
      driver = driver
    ))
  } else if (laps != "all") {
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_drivers('{driver}').pick_lap({laps}).get_telemetry().add_distance().add_driver_ahead()",
      driver = driver, laps = laps
    ))
  } else {
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_drivers('{driver}').get_telemetry().add_distance().add_driver_ahead()",
      driver = driver
    ))
  }
  py_env <- reticulate::py_run_string(paste("tel.SessionTime = tel.SessionTime.dt.total_seconds()",
    "tel.Time = tel.Time.dt.total_seconds()",
    sep = "\n"
  ))

  tel <- reticulate::py_to_r(reticulate::py_get_item(py_env, "tel"))

  tel %>%
    dplyr::mutate(driverCode = driver) %>%
    tibble::tibble() %>%
    janitor::clean_names()
}

#' @inherit load_driver_telemetry title return params
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `get_driver_telemetry()` was renamed to `load_driver_telemetry()` to create a more
#' consistent API.
#' @keywords internal
#' @export

get_driver_telemetry <-
  function(season = get_current_season(),
           round = 1,
           session = "R",
           driver,
           laps = "fastest",
           log_level = "WARNING",
           fastest_only = lifecycle::deprecated(),
           race = lifecycle::deprecated()) {
    lifecycle::deprecate_stop(
      "1.4.0",
      "get_driver_telemetry()",
      "load_driver_telemetry()"
    )
  }
