#' Load Session Data
#'
#' Loads telemetry and general data from the official F1
#' data stream via the fastf1 python library. Data is available from
#' 2018 onward.
#'
#' @param season number from 2018 to 2022 (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @return A session object to be used in other functions.

load_race_session <- function(obj_name, season = 2022, race = 1, session = 'R'){
  message("The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster\n\n")
  reticulate::py_run_string('import fastf1')
  reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{wd}')", wd = getwd()))
  if(is.numeric(race))
    reticulate::py_run_string(glue::glue("{name} = fastf1.get_session({season}, {race}, '{session}')", season = season, race = race, name = obj_name, session = session))
  else
    reticulate::py_run_string(glue::glue("{name} = fastf1.get_session({season}, '{race}', '{session}')", season = season, race = race, name = obj_name, session = session))
  reticulate::py_run_string(glue::glue('{name}.load()', name = obj_name))
}

