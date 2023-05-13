#' Load Lapwise Data
#'
#' Loads lapwise data for a race session.
#'
#' Includes laptime, pit in/out time, tyre information, and track status.
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
#' DEBUG, INFO, WARNING, ERROR and CRITICAL. See \href{https://theoehrly.github.io/Fast-F1/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @import reticulate
#' @return A data frame. Note time information is in seconds, see \href{https://docs.fastf1.dev/time_explanation.html}{fastf1 documentation} for more information on timing.
#' @export
load_race_laps <- function(obj_name="session_laps", season = get_current_season(), race = 1, session = 'R', log_level = "WARNING"){
  s <- load_race_session(obj_name = obj_name, season = season, race = race, session = session, log_level = log_level)

  reticulate::py_run_string(glue::glue("laps={obj}.laps", obj = obj_name))

  reticulate::py_run_string("laps.Time = laps.Time.dt.total_seconds()\nlaps.LapTime = laps.LapTime.dt.total_seconds()\nlaps.PitOutTime = laps.PitOutTime.dt.total_seconds()\nlaps.PitInTime = laps.PitInTime.dt.total_seconds()\nlaps.Sector1SessionTime = laps.Sector1SessionTime.dt.total_seconds()\nlaps.Sector1Time = laps.Sector1Time.dt.total_seconds()\nlaps.Sector2SessionTime = laps.Sector2SessionTime.dt.total_seconds()\nlaps.Sector2Time = laps.Sector2Time.dt.total_seconds()\nlaps.Sector3SessionTime = laps.Sector3SessionTime.dt.total_seconds()\nlaps.Sector3Time = laps.Sector3Time.dt.total_seconds()\nlaps.LapStartTime = laps.LapStartTime.dt.total_seconds()")

  laps <- reticulate::py_run_string('laps')
  invisible(laps$laps)
}
