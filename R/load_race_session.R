#' Load Session Data
#'
#' Loads telemetry and general data from the official F1
#' data stream via the fastf1 python library. Data is available from
#' 2018 onward.
#'
#' @param obj_name name assigned to the loaded session to be referenced later.
#' @param season number from 2018 to current season.
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load Options are FP1, FP2, FP3,
#' Q, S, and R. Default is "R", which refers to Race.
#' @param cache whether the session will get cached or not. Default is set to
#' TRUE (recommended), as this lowers subsequent loading times significantly.
#' Cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' default is the current working directory.
#' @import reticulate
#' @return A session object to be used in other functions.

load_race_session <- function(obj_name, season = 2022, race = 1, session = 'R', cache = T){
  if(season != 'current' & (season < 2018 | season > as.numeric(strftime(Sys.Date(), "%Y")))){
    stop(glue::glue('Year must be between 2018 and {current} (or use "current")', current = as.numeric(strftime(Sys.Date(), "%Y"))))
  }
  if(!(session %in% c("FP1", "FP2", "FP3", "Q", "R", "S"))){
    stop('Session must be one of "FP1", "FP2", "FP3", "Q", "S", or "R"')
  }
  message("The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster\n\n")
  reticulate::py_run_string('import fastf1')
  if(cache)
    reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{cache_dir}')", cache_dir = getOption('f1dataR.cache')))

  py_string<-glue::glue("{name} = fastf1.get_session({season}, ", name = obj_name, season = season)
  if(is.numeric(race)){
    py_string<-glue::glue("{string}{race}, ", string = py_string, race = race)
  } else {
    #season is 'current' and needs quotes
    py_string<-glue::glue("{string}'{race}', ", string = py_string, race = race)
  }
  py_string<-glue::glue("{string}'{session}')", string = py_string, session = session)

  reticulate::py_run_string(py_string)
  reticulate::py_run_string(glue::glue('{name}.load()', name = obj_name))
}
