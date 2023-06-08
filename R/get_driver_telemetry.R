#' Load Telemetry Data for a Driver
#'
#' Receives season, race number, driver code, and an optional fastest lap only
#' argument to output car telemetry for the selected situation.
#'
#' @param season number from 2018 to current season (defaults to current season).
#' @param round number from 1 to 23 (depending on season selected). Also accepts race name.
#' @param session the code for the session to load Options are FP1, FP2, FP3,
#' Q, S, SS, and R. Default is "R", which refers to Race.
#' @param driver three letter driver code (see load_drivers() for a list)
#' @param fastest_only boolean value whether to pick all laps or only the fastest
#' by the driver in that session.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' DEBUG, INFO, WARNING, ERROR and CRITICAL. See \href{https://theoehrly.github.io/Fast-F1/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @importFrom magrittr "%>%"
#' @return A dataframe with telemetry data for selected driver/session.
#' @import reticulate
#' @export

get_driver_telemetry <- function(season = 2022, round = 1, session = 'R', driver, fastest_only = FALSE, log_level="WARNING"){
  load_race_session("session", season = season, round = round, session = session, log_level = log_level)
  if(fastest_only){
    tel <- reticulate::py_run_string(glue::glue("tel =session.laps.pick_driver('{driver}').pick_fastest().get_telemetry().add_distance()",
                                                driver = driver))
    res <- py_tel_to_tibble(tel)
  }else{
    tel <- reticulate::py_run_string(glue::glue("tel =session.laps.pick_driver('{driver}').get_telemetry().add_distance()",
                                                driver = driver))
    res <- py_tel_to_tibble(tel)
  }
  res %>% dplyr::mutate(driverCode = driver)
}

py_tel_to_tibble<-function(py_tel_object){
  # This funciton converts a python object to tibble.
  # Sometimes, the py_to_r has to be called a few times, this calls it as often as needed recursively.
  # Once not a python object, this converts to data frame
  if ("python.builtin.dict" %in% class(py_tel_object)){
    object <- reticulate::py_to_r(py_tel_object)
    object <- py_tel_to_tibble(object)
  } else {
    object <- py_tel_object$tel %>%
      tibble::as_tibble()
  }
  return(object)
}
