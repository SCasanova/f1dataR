#' Load Telemetry Data for a Driver
#'
#' @description Receives season, race number, driver code, and an optional fastest lap only
#' argument to output car telemetry for the selected situation.
#'
#' @param season number from 2018 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season selected). Also accepts race name.
#' @param session the code for the session to load Options are `'FP1'`, `'FP2'`, `'FP3'`,
#' `'Q'`, `'S'`, `'SS'`, and `'R'`. Default is `'R'`, which refers to Race.
#' @param driver three letter driver code (see `load_drivers()` for a list)
#' @param laps which lap's telemetry to return. One of an integer lap number (<= total laps in the race), `fastest`,
#' or `all`. Note that integer lap choice requires `fastf1` version 3.0 or greater.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' `'DEBUG'`, `'INFO'`, `'WARNING'`, `'ERROR'` and `'CRITICAL'`. See \href{https://theoehrly.github.io/Fast-F1/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, use `round`.
#' @param fastest_only `r lifecycle::badge("deprecated")` `fastest_only` is no longer supported, indicated preferred
#' laps in `laps`.
#' @importFrom magrittr "%>%"
#' @return A tibble with telemetry data for selected driver/session.
#' @import reticulate
#' @export
#' @examples
#' \dontrun{
#' telem <- load_driver_telemetry(season = 2023,
#'                                round = 'Bahrain',
#'                                session = 'Q',
#'                                driver = 'HAM',
#'                                laps = 'fastest')
#' }
#'
load_driver_telemetry <- function(season = get_current_season(), round = 1, session = "R", driver, laps = "fastest",
                                  log_level = "WARNING", race = lifecycle::deprecated(),
                                  fastest_only = lifecycle::deprecated()) {

  #Lifecycles
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_warn("1.0.0", "load_driver_telemetry(race)", "load_driver_telemetry(round)")
    round <- race
  }
  if (lifecycle::is_present(fastest_only)) {
    lifecycle::deprecate_warn("1.1.0", "load_driver_telemetry(fastest_only)", "load_driver_telemetry(laps)")
    if (fastest_only) {
      laps <- "fastest"
    } else {
      laps <- "all"
    }
  }

  # Param checks
  if (!(laps %in% c("fastest", "all"))) {
    if (is.numeric(laps)) {
      if (get_fastf1_version() < 3) {
        cli::cli_abort("{.var laps} can only be a lap number if using fastf1 v3.0 or higher")
      }
      if (as.numeric(laps) != as.integer(laps)) {
        cli::cli_abort("{.var laps} must be one of `fastest`, `all` or an integer value")
      }
    } else {
      cli::cli_abort("{.var laps} must be one of `fastest`, `all` or an integer value")
    }
  }

  load_race_session(obj_name = "session", season = season, round = round, session = session, log_level = log_level)

  tryCatch({
      # Only returns a value if session.load() has been successful
      # If it hasn't, retry
      reticulate::py_run_string("session.t0_date")
    }, error = function(e) {
      reticulate::py_run_string("session.load()")
    }
  )

  if (get_fastf1_version() >= 3) {
    add_v3_option <- ".add_driver_ahead()"
  } else {
    add_v3_option <- ""
  }

  if (laps == "fastest") {
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_driver('{driver}').pick_fastest().get_telemetry().add_distance(){opt}",
                                         driver = driver, opt = add_v3_option))
  } else if (laps != "all") {
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_driver('{driver}').pick_lap({laps}).get_telemetry().add_distance(){opt}",
                                         driver = driver, laps = laps, opt = add_v3_option))
  } else {
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_driver('{driver}').get_telemetry().add_distance(){opt}",
                                         driver = driver, opt = add_v3_option))

  }
  py_env <- reticulate::py_run_string(paste("tel.SessionTime = tel.SessionTime.dt.total_seconds()",
                                            "tel.Time = tel.Time.dt.total_seconds()",
                                            sep = "\n"))

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
#' `load_driver_telemetry()` was renamed to `load_driver_telemetry()` to create a more
#' consistent API.
#' @keywords internal
#' @export
get_driver_telemetry <- function(season = get_current_season(), round = 1, session = "R", driver, fastest_only = FALSE,
                                 log_level = "WARNING", race = lifecycle::deprecated()) {
  lifecycle::deprecate_warn("1.0.0", "get_driver_telemetry()", "load_driver_telemetry()")
  load_driver_telemetry(season = season, round = round, session = session, driver = driver, fastest_only = fastest_only,
                        log_level = log_level, race = race)
}
