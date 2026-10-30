#' Get Ergast Content
#'
#' @description Gets Ergast content and returns the processed json object if
#' no Ergast errors are found. This will automatically fall back from https://
#' to http:// if Ergast suffers errors, and will automatically retry up to 10
#' times by each protocol
#'
#' `r lifecycle::badge("deprecated")`
#'
#' Note the Ergast Motor Racing Database API shut down at the end of 2024.
#' This function was replaced by the Jolpica data source.
#'
#' @param url the Ergast URL tail to get from the API (for example,
#' `"{season}/circuits.json?limit=40"` is called from `load_circuits()`).
#' @keywords internal
#' @return the result of `jsonlite::fromJSON` called on Ergast's return content.
#' Further processing is performed by specific functions
get_ergast_content <- function(url) {
  # Function Deprecation Warning
  lifecycle::deprecate_warn(
    "at the end of 2024",
    "get_ergast_content()",
    details = c(
      "i" = "At the end of 2024 season the Ergast Motor Racing Database API was shut down.",
      " " = "Update f1dataR to use the new jolpica-f1 API data source."
    )
  )

  get_jolpica_content(url)
}


#' Get Jolpica Content
#'
#' @description Gets Jolpica-F1 content and returns the processed json object if
#' no  errors are found. This will automatically fall back from https://
#' to http:// if Jolpica suffers errors, and will automatically retry up to 10
#' times by each protocol
#'
#' Note in 2024 this replaced the deprecated Ergast API. Much of the historical data
#' is duplicated in Jolpica
#'
#' @param url the Jolpica URL tail to get from the API (for example,
#' `"{season}/circuits.json"` is called from `load_circuits()`).
#' @param parameters Parameters to add to the url. Typically fills things like `limit`: passed as a `list(limit = 40)`.
#' @keywords internal
#' @return the result of `jsonlite::fromJSON` called on Jolpica's return content.
#' Further processing is performed by specific functions
get_jolpica_content <- function(url, parameters = list(limit = 40)) {
  # Function Code

  # note:
  # Throttles at 500 req/hr (Jolpica's documented sustained limit).
  # Caches requests at option = 'f1dataR.cache' location, if not 'current', 'last', or 'latest' result requested
  # Automatically retries request up to 10 times. Back-off provided in httr2 documentation
  # Automatically retries at http if https fails after retries.

  if (grepl("?", url, fixed = TRUE)) {
    cli::cli_warn(c(
      "x" = "Warning: A {.param url} was provided with parameters.",
      "i" = "Modify your request to pass the parameters as a list"
    ))
  }
  if (!is.list(parameters)) {
    parameters <- as.list(parameters)
  }

  jolpica_raw <- httr2::request("https://api.jolpi.ca/ergast/f1/") %>%
    httr2::req_url_path_append(url) %>%
    httr2::req_url_query(!!!parameters) %>%
    httr2::req_retry(max_tries = 10, backoff = function(x) {
      stats::runif(1, 1, 2^x)
    }) %>%
    httr2::req_user_agent(glue::glue(
      "f1dataR/{ver}",
      ver = utils::installed.packages()["f1dataR", "Version"]
    )) %>%
    httr2::req_throttle(capacity = 500, fill_time_s = 3600) %>%
    httr2::req_error(is_error = ~FALSE)

  jolpica_res <- NULL

  tryCatch(
    {
      jolpica_res <- jolpica_raw %>%
        httr2::req_perform()
    },
    error = function(e) {
      cli::cli_alert_danger(glue::glue(
        "f1dataR: Error getting data from Jolpica:\n{e}",
        e = e
      ))
    }
  )

  # Restart retries to Jolpica with http (instead of https)
  # No testing penalty for Jolpica functioning correct
  # nocov start
  if (
    is.null(jolpica_res) ||
      httr2::resp_is_error(jolpica_res) ||
      httr2::resp_body_string(jolpica_res) == "Unable to select database"
  ) {
    cli::cli_alert_warning(
      "Failure at Jolpica with https:// connection. Retrying as http://."
    )
    tryCatch(
      {
        jolpica_res <- jolpica_raw %>%
          httr2::req_url("http://api.jolpi.ca/ergast/f1/") %>%
          httr2::req_url_path_append(url) %>%
          httr2::req_perform()
      },
      error = function(e) {
        cli::cli_alert_danger(glue::glue(
          "f1dataR: Error getting data from Jolpica:\n{e}",
          e = e
        ))
      }
    )
  }

  if (is.null(jolpica_res)) {
    cli::cli_alert_danger("Couldn't connect to Jolpica to retrieve data.")
    return(NULL)
  }

  if (httr2::resp_is_error(jolpica_res)) {
    cli::cli_alert_danger(glue::glue(
      "Error getting Jolpica data, http status code {code}.\n{msg}",
      code = httr2::resp_status(jolpica_res),
      msg = httr2::resp_status_desc(jolpica_res)
    ))
    return(NULL)
  }

  if (httr2::resp_body_string(jolpica_res) == "Unable to select database") {
    cli::cli_alert_danger(
      "Jolpica is having database trouble. Please try again at a later time."
    )
    return(NULL)
  }
  # nocov end

  # else must be ok
  return(jsonlite::fromJSON(httr2::resp_body_string(jolpica_res)))
}


#' Get Current Season
#'
#' @description Determines current season by System Date. Note returns the season prior to the current year
#' in January and February
#' @export
#' @return Year (four digit number) representation of current season, as numeric.
get_current_season <- function() {
  return(ifelse(
    as.numeric(strftime(Sys.Date(), "%m")) < 3,
    as.numeric(strftime(Sys.Date(), "%Y")) - 1,
    as.numeric(strftime(Sys.Date(), "%Y"))
  ))
}


#' Convert Clock time to seconds
#'
#' @description This function converts clock format time (0:00.000) to seconds (0.000s)
#'
#' @param time character string with clock format (0:00.000)
#' @return A numeric variable that represents that time in seconds
#' @keywords internal
time_to_sec <- function(time) {
  if (length(time) == 0) {
    return(numeric(0))
  }

  subfun <- function(x) {
    if (is.na(x)) {
      return(NA_real_)
    } else if (is.numeric(x)) {
      return(x)
    } else if (x == "") {
      return(NA_real_)
    } else {
      split <- as.numeric(strsplit(x, ":", fixed = TRUE)[[1]])
      if (length(split) == 3) {
        split[1] * 3600 + split[2] * 60 + split[3]
      } else if (length(split) == 2) {
        split[1] * 60 + split[2]
      } else if (length(split) == 1) {
        split
      }
    }
  }
  v_tts <- Vectorize(subfun, USE.NAMES = FALSE)

  v_tts(time)
}


#' Check Season Argument
#'
#' @description Internal helper that validates a `season` argument against the minimum season
#' supported by the calling function, and resolves `"current"` to a numeric year. Centralises the
#' `season != "current" && (season < min_season || season > get_current_season())` check that was
#' previously duplicated across every loader.
#'
#' @param season the `season` argument as passed by the caller (numeric, coercible character, or `"current"`).
#' @param min_season the minimum season supported by the calling function (e.g. `1950`, `2003`, `2011`, `2018`).
#'
#' @return invisibly, `season` resolved to a numeric year (`get_current_season()` if `season == "current"`).
#' Aborts with a `cli::cli_abort()` message if `season` is invalid.
#' @keywords internal
check_season_arg <- function(season, min_season) {
  season_num <- if (identical(season, "current")) {
    get_current_season()
  } else {
    suppressWarnings(as.numeric(season))
  }

  if (
    length(season_num) != 1 ||
      is.na(season_num) ||
      season_num < min_season ||
      season_num > get_current_season()
  ) {
    cli::cli_abort(
      '{.var season} must be between {min_season} and {get_current_season()} (or use "current")'
    )
  }

  invisible(season_num)
}


#' Check Round Argument
#'
#' @description Internal helper that validates a `round` argument. `round` must be `"last"`, a
#' positive whole number (numeric or a numeric-looking character string), or, when `allow_name = TRUE`,
#' an arbitrary non-empty race-name string (as accepted by the FastF1-backed loaders).
#'
#' @param round the `round` argument as passed by the caller.
#' @param allow_name whether a non-numeric race-name string is also acceptable (used by the
#' FastF1-backed loaders such as `load_race_session()`); Jolpica loaders should leave this `FALSE`.
#'
#' @return invisibly `TRUE`. Aborts with a `cli::cli_abort()` message if `round` is invalid.
#' @keywords internal
check_round_arg <- function(round, allow_name = FALSE) {
  if (identical(round, "last")) {
    return(invisible(TRUE))
  }

  round_num <- suppressWarnings(as.numeric(round))

  if (
    length(round) != 1 ||
      (is.character(round) && is.na(round)) ||
      (length(round_num) == 1 &&
        !is.na(round_num) &&
        (round_num != as.integer(round_num) || round_num < 1))
  ) {
    cli::cli_abort(
      '{.var round} must be a positive whole number{if (allow_name) " or race name" else ""} (or "last")'
    )
  }

  if (is.na(round_num) && !allow_name) {
    cli::cli_abort('{.var round} must be a positive whole number (or "last")')
  }

  if (is.na(round_num) && (!is.character(round) || !nzchar(round))) {
    cli::cli_abort('{.var round} must be a non-empty race name (or "last")')
  }

  invisible(TRUE)
}


#' Check FastF1 Session Loaded
#'
#' @description Used to verify that the fastf1 session is loaded before trying to work with it.
#'
#' Prevents errors in automated processing code.
#'
#' @param session_name Name of the python session object. For internal functions, typically `session`.
#'
#' @return invisible TRUE, no real return, called for effect
#'
#' @keywords internal
check_ff1_session_loaded <- function(session_name = "session") {
  tryCatch(
    {
      # Only returns a value if session.load() has been successful
      # If it hasn't, retry
      reticulate::py_run_string(glue::glue(
        "{session_name}.t0_date",
        session_name = session_name
      ))
    },
    error = function(e) {
      reticulate::py_run_string(glue::glue(
        "{session_name}.load()",
        session_name = session_name
      ))
    }
  )
  invisible(TRUE)
}


#' Check FastF1/F1 Live Timing network status
#'
#' @description check the network connection to livetiming.formula1.com, the datasource for FastF1.
#' Requires a specific session path be provided as the 'homepage' requires authentication to load.
#'
#' @param path session path (available from the session at session.api_path)
#'
#' @return True if a connection is available, else FALSE
#'
#' @keywords internal
#' @noRd
check_ff1_network_connection <- function(path = NA_character_) {
  if (is.na(path)) {
    cli::cli_abort("f1dataR: Specific race path must be provided")
  }

  status <- NULL

  tryCatch(
    {
      ff1raw <- httr2::request("https://livetiming.formula1.com/") %>%
        httr2::req_url_path_append(path) %>%
        httr2::req_url_path_append("Index.json") %>%
        httr2::req_retry(max_tries = 5) %>%
        httr2::req_user_agent(glue::glue(
          "f1dataR/{ver}",
          ver = utils::installed.packages()["f1dataR", "Version"]
        )) %>%
        httr2::req_throttle(capacity = 500, fill_time_s = 3600) %>%
        httr2::req_error(is_error = ~FALSE)
      status <- ff1raw %>%
        httr2::req_perform()
    },
    error = function(e) {
      cli::cli_alert_danger(glue::glue(
        "f1dataR: Error getting data from F1 Live Timing:\n{e}",
        e = e
      ))
    }
  )
  if (is.null(status)) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}


#' Check FastF1 Version
#'
#' @description
#' This function checks the version of `FastF1` and ensures it's at or above the minimum supported version for
#' `f1dataR` (currently requires 3.9.0 or better).
#'
#' This function is a light wrapper around get_fastf1_version()
#'
#' @return Invisibly `TRUE` if not raising an error for unsupported `FastF1` version.
#'
#' @keywords internal
check_ff1_version <- function() {
  version <- get_fastf1_version()
  if (is.na(version)) {
    cli::cli_abort(
      "The {.pkg FastF1} Python package could not be found. {.pkg f1dataR} requires {.pkg FastF1} version 3.9.0 or newer."
    )
  }
  if (version < "3.9.0") {
    cli::cli_abort(c(
      "An old version of {.pkg FastF1} is in use. {.pkg f1dataR} requires {.pkg FastF1} version 3.9.0 or newer.",
      x = "F1 live timing now requires authentication, which is supported from {.pkg FastF1} version 3.9.0.",
      i = "Update with {.code reticulate::py_install(\"fastf1\", pip = TRUE)} or restart R to let {.pkg reticulate} resolve the requirement."
    ))
  }
  invisible(TRUE)
}


#' Get current FastF1 version
#'
#' @description
#' Gets the current installed FastF1 version available (via `reticulate`) to the function.
#' Displays a note if significantly out of date.
#' @export
#' @return version as class `package_version`, or `NA` if `fastf1` is not installed
get_fastf1_version <- function() {
  reticulate::py_available(initialize = TRUE)
  ver <- reticulate::py_list_packages() %>%
    dplyr::filter(.data$package == "fastf1") %>%
    dplyr::pull("version")
  if (length(ver) == 0) {
    cli::cli_warn(
      "Ensure {.pkg fastf1} Python package is installed.",
    )
    return(NA)
  }

  return(package_version(ver))
}


#' Add Column if Absent
#'
#' @description Adds a column (with the name specified in column_name) of NA values to a data.frame or tibble. If that
#' column already exists, no change will be made to data. NA value type (character, integer, real, logical)
#' may be specified.
#'
#' @param data a data.frame or tibble to which a column may be added
#' @param column_name the name of the column to be added if it doesn't exist
#' @param na_type the type of NA value to use for the column values. Default to basic `NA`
#'
#' @return the data.frame as provided (converted to tibble)
#' @keywords internal
add_col_if_absent <- function(data, column_name, na_type = NA) {
  if (length(na_type) != 1 || !is.na(na_type)) {
    cli::cli_abort(c(
      x = "{.arg na_type} must be provided as an actual {.code NA_type_} (for example, {.val NA_character_})."
    ))
  }
  if (!(inherits(data, "data.frame"))) {
    cli::cli_abort(c(
      x = "{.arg data} must be provided as a {.code data.frame} or {.code tibble}."
    ))
  }
  if (!(length(column_name) == 1) | !(inherits(column_name, "character"))) {
    cli::cli_abort(c(
      x = "{.arg column_name} must be provided as a single {.code character} value."
    ))
  }
  if (!(column_name %in% colnames(data))) {
    data[, column_name] <- na_type
  }
  return(dplyr::as_tibble(data))
}

# nocov start

#' @noRd
dummy <- function() {
  # this function creates and cleans a dummy table to clear r cmd check notes for
  # janitor, tibble and tidyr
  dummy <- tibble::tibble("Dummy" = c(1:5, NA)) %>%
    janitor::clean_names() %>%
    tidyr::drop_na()
  invisible(NULL)
}

# nocov end
