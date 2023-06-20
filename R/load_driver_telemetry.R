#' Load Telemetry Data for a Driver
#'
#' Receives season, race number, driver code, and an optional fastest lap only
#' argument to output car telemetry for the selected situation.
#'
#' @param season number from 2018 to current season (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected). Also accepts race name.
#' @param round number from 1 to 23 (depending on season selected). Also accepts race name.
#' @param session the code for the session to load Options are FP1, FP2, FP3,
#' Q, S, SS, and R. Default is "R", which refers to Race.
#' @param driver three letter driver code (see load_drivers() for a list)
#' @param fastest_only boolean value whether to pick all laps or only the fastest
#' by the driver in that session.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' DEBUG, INFO, WARNING, ERROR and CRITICAL. See \href{https://theoehrly.github.io/Fast-F1/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @importFrom magrittr "%>%"
#' @return A tibble with telemetry data for selected driver/session.
#' @import reticulate
#' @export

load_driver_telemetry <- function(season = get_current_season, round =1, session = 'R', driver, fastest_only = FALSE, log_level="WARNING", race = lifecycle::deprecated()){
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_warn("0.4.1", "load_driver_telemetry(race)", "load_driver_telemetry(round)")
    round <- race
  }
  load_race_session("session", season = season, round = round, session = session, log_level = log_level)
  if(fastest_only){
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_driver('{driver}').pick_fastest().get_telemetry().add_distance().add_driver_ahead()",
                                                driver = driver))

  }else{
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_driver('{driver}').get_telemetry().add_distance().add_driver_ahead()",
                                                driver = driver))

  }
  py_env <- reticulate::py_run_string(paste("tel.SessionTime = tel.SessionTime.dt.total_seconds()",
                                  "tel.Time = tel.Time.dt.total_seconds()",
                                  sep = "\n"))

  tel <- reticulate::py_to_r(reticulate::py_get_item(py_env, 'tel'))

  tel %>%
    dplyr::mutate(driverCode = driver) %>%
    tibble::tibble() %>%
    janitor::clean_names()
}

#' Load Telemetry Data for a Driver
#'
#' Receives season, race number, driver code, and an optional fastest lap only
#' argument to output car telemetry for the selected situation.
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `load_driver_telemetry()` was renamed to `load_driver_telemetry()` to create a more
#' consistent API.
#' @keywords internal
#' @export


get_driver_telemetry <- function(season = get_current_season(), round =1, session = 'R', driver, fastest_only = FALSE, log_level="WARNING", race = lifecycle::deprecated()){
  lifecycle::deprecate_warn("0.4.1", "get_driver_telemetry()", "load_driver_telemetry()")
  load_driver_telemetry(season = season, round = round, session = session, driver = driver, fastest_only = fastest_only, log_level = log_level, race = race)
}
