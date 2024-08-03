#' Get Driver style
#'
#' @description Driver Style gets the FastF1 style for a driver for
#' a session -  this includes team colour and a reasonably consistent
#' (but not guaranteed) line/marker style. Based on FastF1's
#' [get_driver_style](https://docs.fastf1.dev/plotting.html#fastf1.plotting.get_driver_style).
#'
#' @param driver Driver abbreviation or name (FastF1 fuzzy-matches).
#' @param season A season corresponding to the race being referenced for collecting
#' driver plotting style.
#' @param round A season corresponding to the race being referenced for collecting
#' driver plotting style.
#'
#' @return a named list of graphic parameters for the provided driver
get_driver_style <- function(driver, season = get_current_season(), round = 1) {
  # checks
  check_ff1_version()
  if (package_version(get_fastf1_version()) < "3.4") {
    cli::cli_abort("{.fn get_driver_style} requires FastF1 version 3.4.0 or later")
  }
  if (!is.character(driver) & length(driver) != 1) {
    cli::cli_abort("{.var driver} must be a character vector of length one.")
  }

  # Function Code
  status <- load_race_session(
    obj_name = "session", season = season, round = round,
    session = "R", log_level = "WARNING"
  )

  reticulate::py_run_string("import fastf1")
  reticulate::py_run_string("from fastf1.plotting import get_driver_style")

  py_string <- glue::glue("session = fastf1.get_session({season}, ", season = season)
  if (is.numeric(round)) {
    py_string <- glue::glue("{py_string}{round}, 'R')", py_string = py_string, round = round)
  } else {
    # Character race, so need quotes around it
    py_string <- glue::glue("{py_string}'{round}', 'R')", py_string = py_string, round = round)
  }
  reticulate::py_run_string(py_string)

  py_string <- glue::glue("driverstyle = get_driver_style('{driver}', ['linestyle', 'marker', 'color'], session)",
    driver = driver
  )
  py_env <- reticulate::py_run_string(py_string)

  driverstyle <- reticulate::py_to_r(reticulate::py_get_item(py_env, "driverstyle"))

  driverstyle$driver <- driver

  return(driverstyle)
}
