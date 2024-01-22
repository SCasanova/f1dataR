#' Load Lapwise Data
#'
#' @description Loads lapwise data for a race session.
#'
#' Includes each driver's each lap's laptime, pit in/out time, tyre information, track status, and (optionally) weather information.
#' The resulting data frame contains a column for the session type. Note that quali sessions are labelled Q1, Q2 & Q3.
#'
#' Cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' default is the current working directory.
#'
#' If you have trouble with errors mentioning 'fastf1' or 'get_fastf1_version()' read the
#' 'Setup FastF1 Connection vignette (run \code{vignette('setup_fastf1', 'f1dataR')}).
#'
#' @param season number from 2018 to current season. Defaults to current season.
#' @param round number from 1 to 23 (depending on season selected). Also accepts race name.
#' @param session the code for the session to load Options are `'FP1'`, `'FP2'`, `'FP3'`,
#' `'Q'`, `'S'`, `'SS'` and `'R'` Default is `'R'`, which refers to Race.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' `'DEBUG'`, `'INFO'`, `'WARNING'`, `'ERROR'` and `'CRITICAL'`. See
#' \href{https://docs.fastf1.dev/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @param add_weather Whether to add weather information to the laps. See
#' \href{https://docs.fastf1.dev/core.html#fastf1.core.Laps.get_weather_data}{fastf1 documentation} for info on weather.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, use `round`.
#' @import reticulate
#' @return A tibble. Note time information is in seconds, see \href{https://docs.fastf1.dev/time_explanation.html}{fastf1 documentation} for more information on timing.
#' @export
#'
load_session_laps <- function(season = get_current_season(), round = 1, session = "R", log_level = "WARNING",
                              add_weather = FALSE, race = lifecycle::deprecated()) {
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop("1.4.0", "load_session_laps(race)", "load_session_laps(round)")
    round <- race
  }

  if (get_fastf1_version()$major < 3) {
    cli::cli_alert_warning("An old version of FastF1 is in use. Additional data is provided if using FastF1 v3.0.0 or later.")
  }

  load_race_session(obj_name = "session", season = season, round = round, session = session, log_level = log_level)

  tryCatch(
    {
      # Only returns a value if session.load() has been successful
      # If it hasn't, retry
      reticulate::py_run_string("session.t0_date")
    },
    error = function(e) {
      reticulate::py_run_string("session.load()")
    }
  )

  reticulate::py_run_string("laps = session.laps")
  if (add_weather) {
    reticulate::py_run_string(paste("import pandas as pd",
      "weather_data = laps.get_weather_data()",
      "laps = laps.reset_index(drop=True)",
      "weather_data = weather_data.reset_index(drop=True)",
      "laps = pd.concat([laps, weather_data.loc[:, ~(weather_data.columns == 'Time')]], axis=1)",
      sep = "\n"
    ))
  }

  if (session == "Q" && get_fastf1_version()$major >= 3) {
    # prepping for Q1/Q2/Q3 labels - this has to happen before timedelta64 is converted to seconds
    reticulate::py_run_string(paste("q1, q2, q3 = session.laps.split_qualifying_sessions()",
      "q1len = len(q1.index)",
      "q2len = len(q2.index)",
      "q3len = len(q3.index)",
      sep = "\n"
    ))
  }

  # The FF1 function returns timedelta64 results for the below columns, which don't properly convert to
  # R compatible types. Instead, use the dt.total_seconds() function inherent to the type to convert in
  # Python before extracting the DataFrame to the R data.frame
  py_env <- reticulate::py_run_string(paste("laps.Time = laps.Time.dt.total_seconds()",
    "laps.LapTime = laps.LapTime.dt.total_seconds()",
    "laps.PitOutTime = laps.PitOutTime.dt.total_seconds()",
    "laps.PitInTime = laps.PitInTime.dt.total_seconds()",
    "laps.Sector1SessionTime = laps.Sector1SessionTime.dt.total_seconds()",
    "laps.Sector1Time = laps.Sector1Time.dt.total_seconds()",
    "laps.Sector2SessionTime = laps.Sector2SessionTime.dt.total_seconds()",
    "laps.Sector2Time = laps.Sector2Time.dt.total_seconds()",
    "laps.Sector3SessionTime = laps.Sector3SessionTime.dt.total_seconds()",
    "laps.Sector3Time = laps.Sector3Time.dt.total_seconds()",
    "laps.LapStartTime = laps.LapStartTime.dt.total_seconds()",
    sep = "\n"
  ))
  laps <- reticulate::py_to_r(reticulate::py_get_item(py_env, "laps"))

  laps <- laps %>%
    dplyr::mutate("Time" = .data$Time)

  if (session == "Q" && get_fastf1_version()$major >= 3) {
    # pull the lengths of each Quali session from the python env.
    q1len <- reticulate::py_to_r(reticulate::py_get_item(py_env, "q1len"))
    q2len <- reticulate::py_to_r(reticulate::py_get_item(py_env, "q2len"))
    q3len <- reticulate::py_to_r(reticulate::py_get_item(py_env, "q3len"))

    laps$SessionType <- c(rep("Q1", q1len), rep("Q2", q2len), rep("Q3", q3len))
  } else {
    laps$SessionType <- session
  }
  laps %>%
    tibble::tibble() %>%
    janitor::clean_names()
}
