#' Load Session Data
#'
#' Loads telemetry and general data from the official F1
#' data stream via the fastf1 python library. Data is available from
#' 2018 onward.
#'
#' The data loaded can optionally be assigned to a R variable, and then interrogated for
#' session data streams. See the \href{https://theoehrly.github.io/Fast-F1/}{fastf1 documentation}
#' for more details on the data returned by the python API.
#'
#' @param obj_name name assigned to the loaded session to be referenced later.
#' @param season number from 2018 to current season. Defaults to current season
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load Options are FP1, FP2, FP3,
#' Q, S, and R. Default is "R", which refers to Race.
#' Cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' default is the current working directory.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' DEBUG, INFO, WARNING, ERROR and CRITICAL. See \link(https://theoehrly.github.io/Fast-F1/fastf1.html#configure-logging-verbosity)
#' @import reticulate
#' @return A session object to be used in other functions invisibly.
#' @export
load_race_session <- function(obj_name="session", season = get_current_season(), race = 1, session = 'R', log_level = "WARNING"){
  if(season != 'current' & (season < 2018 | season > get_current_season())){
    stop(glue::glue('Year must be between 2018 and {current} (or use "current")',
                    current = get_current_season()))
  }
  if(!(session %in% c("FP1", "FP2", "FP3", "Q", "R", "S"))){
    stop('Session must be one of "FP1", "FP2", "FP3", "Q", "S", or "R"')
  }
  if(season == 'current'){
    season <- get_current_season()
  }

  log_level <- match.arg(log_level, c('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL', TRUE), several.ok = FALSE)
  if(log_level == TRUE)
  if(log_level %in% c("DEBUG", "INFO")){
    message("The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster\n\n")
  }

  reticulate::py_run_string('import fastf1')
  if(get_fastf1_version() >= 3){
    reticulate::py_run_string(glue::glue("fastf1.set_log_level('{log_level}')", log_level = log_level))
  }
  reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{cache_dir}')", cache_dir = getOption('f1dataR.cache')))

  py_string<-glue::glue("{name} = fastf1.get_session({season}, ", name = obj_name, season = season)
  if(is.numeric(race)){
    py_string<-glue::glue("{py_string}{race}, '{session}')",
                          py_string = py_string, race = race, session = session)
  } else {
    #Character race, so need quotes around it
    py_string<-glue::glue("{py_string}'{race}', '{session}')",
                          py_string = py_string, race = race, session = session)
  }

  reticulate::py_run_string(py_string)

  session <- reticulate::py_run_string(glue::glue('{name}.load()', name = obj_name))

  invisible(session[obj_name])
}
