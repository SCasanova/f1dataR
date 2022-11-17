#' Load Telemetry Data for a Driver
#'
#' Recieves season, race number, driver code, and an optional fastest lap only
#' argument to output car telemetry for the selected situation.
#'
#' @param season number from 2018 to 2022 (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load Options are FP1, FP2, FP3,
#' Q, and R. DEfault is "R", which refers to Race.
#' @param driver three letter driver code (see load_drivers() for a list)
#' @param fastest_only boolean value whether to pick all laps or only the fastest
#' by the driver in that session.
#' @importFrom magrittr "%>%"
#' @return A dataframe with telemetry data for selected driver/session.
#' @export

get_driver_telemetry <- function(season = 2022, race = 'last', session = 'R', driver, fastest_only = FALSE){
  load_race_session("session", season, race, session)
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
  if ("python.builtin.dict" %in% class(py_object)){
    object <- reticulate::py_to_r(py_tel_object)
    py_tel_to_tibble(object)
  } else {
    object <- py_tel_object$tel %>%
      tibble::as_tibble()
  }
  return(object)
}
