

#' @title Get Aesthetics
#'
#' @description Various aesthetics can be retrieved for a driver or team for a specific session/event.
#'
#' `get_driver_style()` gets the FastF1 style for a driver for a session -  this includes team colour and line/marker
#' style which should be reasonably (but not guaranteed) consistent across a season. Based on FastF1's
#' [get_driver_style](https://docs.fastf1.dev/plotting.html#fastf1.plotting.get_driver_style).
#'
#' `get_driver_color()` and its alias `get_driver_colour()` return a hexidecimal RGB colour code for
#' a driver at a given season & race. Data is provided by the python FastF1 package. Note that, in contrast
#' to earlier versions, both drivers for a team will be provided the same color. Use `get_driver_style()` to
#' develop a unique marker/linestyle for each driver in a team.
#'
#' `get_team_color()` and its alias `get_team_colour()` return a hexidecimal RGB colour code for a
#' a team at a given season & race. Data is provided by the python FastF1 package.
#'
#' @param driver Driver abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#' @param team Team abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#' @param season A season corresponding to the race being referenced for collecting
#' colour/style.
#' @param round A season corresponding to the race being referenced for collecting
#' colour/style.
#'
#' @return for `get_driver_style()` a named list of graphic parameters for the provided driver,
#' plus the driver identifier provided and the official abbreviation matched to that driver
#' (names are `linestyle`, `marker`, `color`, `driver`, `abbreviation`).
#'
#' for `get_driver_color()` and `get_team_color()`, a hexidecimal RGB color value.
#'
#' @name get_aesthetics
#'
#' @examples
#' if (interactive()) {
#'   # To get a specific season/race, specify them.
#'   get_driver_style(driver = "ALO", season = 2024, round = 3)
#'
#'   # For drivers who haven't moved around recently, get their current season's style:
#'   get_driver_style(driver = "LEC")
#'
#'   get_team_color(team = "Alpine", season = 2023, round = 1)
#' }
#'
NULL



#' @inherit get_aesthetics params description examples
#' @export
#' @rdname get_aesthetics
get_driver_style <- function(driver, season = get_current_season(), round = 1) {
  # checks
  if (!is.character(driver) & length(driver) != 1) {
    cli::cli_abort("{.var driver} must be a character vector of length one.")
  }

  get_session(season = season, round = round)

  py_string <- paste(
    glue::glue("driverstyle = get_driver_style('{driver}', ['linestyle', 'marker', 'color'], session)", driver = driver),
    glue::glue("abbreviation = get_driver_abbreviation('{driver}', session)", driver = driver),
    sep = "\n"
  )

  reticulate::py_run_string("from fastf1.plotting import get_driver_style, get_driver_abbreviation")
  py_env <- reticulate::py_run_string(py_string)

  driverstyle <- reticulate::py_to_r(reticulate::py_get_item(py_env, "driverstyle"))

  abbreviation <- reticulate::py_to_r(reticulate::py_get_item(py_env, "abbreviation"))

  driverstyle$driver <- driver
  driverstyle$abbreviation <- abbreviation

  return(driverstyle)
}


#' @title Get Driver Color
#'
#' @inherit get_aesthetics description examples
#'
#' @param driver Driver abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#' @param season A season corresponding to the race being referenced for collecting color.
#' @param round A season corresponding to the race being referenced for collecting color.
#'
#' @export
get_driver_color <- function(driver, season = get_current_season(), round = 1) {
  # checks
  if (!is.character(driver) & length(driver) != 1) {
    cli::cli_abort("{.var driver} must be a character vector of length one.")
  }

  get_session(season = season, round = round)

  py_string <- glue::glue("drivercolor = get_driver_color('{driver}', session)",
                          driver = driver
  )

  reticulate::py_run_string("from fastf1.plotting import get_driver_color")
  py_env <- reticulate::py_run_string(py_string)

  drivercolor <- reticulate::py_to_r(reticulate::py_get_item(py_env, "drivercolor"))

  return(drivercolor)
}


#' @title Get Driver Colour
#'
#' @inherit get_aesthetics description examples
#'
#' @param driver Driver abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#' @param season A season corresponding to the race being referenced for collecting colour.
#' @param round A season corresponding to the race being referenced for collecting colour.
#'
#' @export
get_driver_colour <- function(driver, season = get_current_season(), round = 1){
  get_driver_color(driver = driver, season = season, round = round)
}


#' @title Get Team Color
#'
#' @inherit get_aesthetics description examples
#'
#' @param team Team abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#' @param season A season corresponding to the race being referenced for collecting
#' color
#' @param round A season corresponding to the race being referenced for collecting
#' color
#'
#' @export
get_team_color <- function(team, season = get_current_season, round = 1){
  # checks
  if (!is.character(team) & length(team) != 1) {
    cli::cli_abort("{.var driver} must be a character vector of length one.")
  }

  get_session(season = season, round = round)

  py_string <- glue::glue("teamcolor = get_team_color('{team}', session)",
                          team = team
  )

  reticulate::py_run_string("from fastf1.plotting import get_team_color")
  py_env <- reticulate::py_run_string(py_string)

  teamcolor <- reticulate::py_to_r(reticulate::py_get_item(py_env, "teamcolor"))

  return(teamcolor)
}


#' @title Get Team Colour
#'
#' @inherit get_aesthetics description examples
#'
#' @param team Team abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#' @param season A season corresponding to the race being referenced for collecting colour.
#' @param round A season corresponding to the race being referenced for collecting colour.
#'
#' @export
get_team_colour <- function(team, season = get_current_season, round = 1){
  get_team_color(team = team, season = season, round = round)
}


#' Get Session
#'
#' @description This preps a `fastf1.get_session()` python call and returns invisibly the python environment
#'
#' @param season number from 2018 to current season. Defaults to current season.
#' @param round number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load. Options are `'FP1'`, `'FP2'`, `'FP3'`,
#' `'Q'`, `'S'`, `'SS'`,`'SQ'`, and `'R'`. Default is `'R'`, which refers to Race.
#'
#' @return invisibly, the python environment
#' @keywords internal
get_session <- function(season = get_current_season(), round = 1, session = "R") {
  # checks
  check_ff1_version()
  if (package_version(get_fastf1_version()) < "3.4") {
    cli::cli_abort("{.fn get_driver_style} requires FastF1 version 3.4.0 or later")
  }

  # Function Code
  reticulate::py_run_string("import fastf1")
  reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{cache_dir}')", cache_dir = f1datar_cache))

  py_string <- glue::glue("session = fastf1.get_session({season}, ", season = season)
  if (is.numeric(round)) {
    py_string <- glue::glue("{py_string}{round}, 'R')", py_string = py_string, round = round)
  } else {
    # Character race, so need quotes around it
    py_string <- glue::glue("{py_string}'{round}', 'R')", py_string = py_string, round = round)
  }
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {cli::cli_abort(c("Error loading FastF1 session.",
                                          "x" = as.character(e)))}
  )
  invisible(py_env)
}
