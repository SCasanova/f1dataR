#' Load Lapwise Data
#'
#' @description Loads lapwise data for a race session.
#'
#' Includes each driver's each lap's laptime, pit in/out time, tyre information, track status, and (optionally) weather information.
#' The resulting data frame contains a column for the session type. Note that quali sessions are labelled
#' Q1, Q2 & Q3, and sprint qualifying sessions (`session = 'SQ'`) are labelled SQ1, SQ2 & SQ3.
#'
#' Cache directory can be set by setting `options(f1dataR.cache = [cache dir])`.
#' The default option is `"memory"`; when the option is `"memory"`, `"off"`, or
#' `"filesystem"`, the underlying FastF1 HTTP cache is written to `tempdir()`.
#'
#' @inheritParams load_race_session
#' @param add_weather Whether to add weather information to the laps. See
#' \href{https://docs.fastf1.dev/core.html#fastf1.core.Laps.get_weather_data}{fastf1 documentation} for info on weather.
#'
#' @return A tibble with (at least) columns `driver`, `lap`, `time`, `lap_time`, `stint`,
#' `compound`, and `session_type`. Additional columns are provided by FastF1, see
#' \href{https://docs.fastf1.dev/core.html#fastf1.core.Laps}{fastf1 documentation} for more
#' information on available columns. Note time information is in seconds, see
#' \href{https://docs.fastf1.dev/time_explanation.html}{fastf1 documentation} for more information
#' on timing. Returns `NULL` if the session fails to load.
#' @export
load_session_laps <- function(
  season = get_current_season(),
  round = 1,
  session = "R",
  log_level = "WARNING",
  add_weather = FALSE,
  race = lifecycle::deprecated()
) {
  # Deprecation Checks
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop(
      "1.4.0",
      "load_session_laps(race)",
      "load_session_laps(round)"
    )
  }
  check_ff1_version()
  check_round_arg(round, allow_name = TRUE)

  # Function Code
  status <- load_race_session(
    obj_name = "session",
    season = season,
    round = round,
    session = session,
    log_level = log_level
  )

  if (is.null(status)) {
    # Failure to load - escape
    return(NULL)
  }

  reticulate::py_run_string("laps = session.laps")
  if (add_weather) {
    reticulate::py_run_string(paste(
      "import pandas as pd",
      "weather_data = laps.get_weather_data()",
      "laps = laps.reset_index(drop=True)",
      "weather_data = weather_data.reset_index(drop=True)",
      "laps = pd.concat([laps, weather_data.loc[:, ~(weather_data.columns == 'Time')]], axis=1)",
      sep = "\n"
    ))
  }

  if (session %in% c("Q", "SQ")) {
    # prepping for Q1/Q2/Q3 labels - this has to happen before timedelta64 is converted to seconds
    reticulate::py_run_string(paste(
      "q1, q2, q3 = session.laps.split_qualifying_sessions()",
      "q1_idx = list(q1.index)",
      "q2_idx = list(q2.index)",
      "q3_idx = list(q3.index)",
      "laps_idx = list(session.laps.index)",
      sep = "\n"
    ))
  }

  # The FF1 function returns timedelta64 results for the below columns, which don't properly convert to
  # R compatible types. Instead, use the dt.total_seconds() function inherent to the type to convert in
  # Python before extracting the DataFrame to the R data.frame
  py_env <- reticulate::py_run_string(paste(
    "laps.Time = laps.Time.dt.total_seconds()",
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

  if (session %in% c("Q", "SQ")) {
    # pull the original row index and the per-segment indices from the python env,
    # so labels can be joined by index rather than assumed positionally.
    laps_idx <- reticulate::py_to_r(reticulate::py_get_item(py_env, "laps_idx"))
    q1_idx <- reticulate::py_to_r(reticulate::py_get_item(py_env, "q1_idx"))
    q2_idx <- reticulate::py_to_r(reticulate::py_get_item(py_env, "q2_idx"))
    q3_idx <- reticulate::py_to_r(reticulate::py_get_item(py_env, "q3_idx"))

    labels <- if (session == "Q") {
      c("Q1", "Q2", "Q3")
    } else {
      c("SQ1", "SQ2", "SQ3")
    }

    session_type <- rep(NA_character_, length(laps_idx))
    session_type[laps_idx %in% q1_idx] <- labels[1]
    session_type[laps_idx %in% q2_idx] <- labels[2]
    session_type[laps_idx %in% q3_idx] <- labels[3]

    laps$SessionType <- session_type
  } else {
    laps$SessionType <- session
  }
  laps %>%
    tibble::tibble() %>%
    janitor::clean_names()
}
