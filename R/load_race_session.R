#' Load Session Data
#'
#' Loads telemetry and general data from the official F1
#' data stream via the fastf1 python library. Data is available from
#' 2018 onward.
#'
#' @param obj_name name assigned to the loaded session to be referenced later.
#' @param season number from 2018 to current season (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load Options are FP1, FP2, FP3,
#' Q, S, and R. Default is "R", which refers to Race.
#' @param cache whether the seesion will get cached or not. Default is set to
#' TRUE (recommended), as this lowers subsequent loading times significantly.
#' @return A session object to be used in other functions.

load_race_session <- function(obj_name, season = 'current', race = 1, session = 'R', cache = T){
  if(season != 'current' & (season < 2018 | season > as.numeric(strftime(Sys.Date(), "%Y")))){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")', current = as.numeric(strftime(Sys.Date(), "%Y"))))
  }
  if(!(session %in% c("FP1", "FP2", "FP3", "Q", "R", "S"))){
    stop('Session must be one of "FP1", "FP2", "FP3", "Q", "S", or "R"')
  }
  message("The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster\n\n")
  reticulate::py_run_string('import fastf1')
  if(cache)
    reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{wd}')", wd = getwd()))
  if(is.numeric(race))
    reticulate::py_run_string(glue::glue("{name} = fastf1.get_session({season}, {race}, '{session}')", season = season, race = race, name = obj_name, session = session))
  else
    reticulate::py_run_string(glue::glue("{name} = fastf1.get_session({season}, '{race}', '{session}')", season = season, race = race, name = obj_name, session = session))
  reticulate::py_run_string(glue::glue('{name}.load()', name = obj_name))
}

