#' Load Session Data
#'
#' Loads telemetry and general data from the official F1
#' data stream via the fastf1 python library. Data is available from
#' 2018 onward.
#'
#' @param obj_name name assigned to the loaded session to be referenced later.
#' @param season number from 2018 to 2022 (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load Options are FP1, FP2, FP3,
#' Q, and R. Default is "R", which refers to Race.
#' @param cache whether the seesion will get cached or not. Default is set to
#' TRUE (recommended), as this lowers subsequent loading times significantly.
#' Cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' default is the current working directory.
#' @return A session object to be used in other functions.

load_race_session <- function(obj_name, season = 2022, race = 1, session = 'R', cache = T){
  if(season != 'current' & (season < 2018 | season > 2022)){
    stop('Year must be between 1950 and 2022 (or use "current")')
  }
  message("The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster\n\n")
  reticulate::py_run_string('import fastf1')
  if(cache)
    reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{cache_dir}')", cache_dir = getOption('f1dataR.cache')))
  if(is.numeric(race))
    reticulate::py_run_string(glue::glue("{name} = fastf1.get_session({season}, {race}, '{session}')", season = season, race = race, name = obj_name, session = session))
  else
    reticulate::py_run_string(glue::glue("{name} = fastf1.get_session({season}, '{race}', '{session}')", season = season, race = race, name = obj_name, session = session))
  reticulate::py_run_string(glue::glue('{name}.load()', name = obj_name))
}

