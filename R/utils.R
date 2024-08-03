#' Get Ergast Content
#'
#' @description Gets Ergast content and returns the processed json object if
#' no Ergast errors are found. This will automatically fall back from https://
#' to http:// if Ergast suffers errors, and will automatically retry up to 5
#' times by each protocol
#'
#' `r lifecycle::badge("deprecated")`
#'
#' Note the Ergast Motor Racing Database API will shut down at the end of 2024.
#' This function willbe replaced with a new data-source when one is made available.
#'
#' @param url the Ergast URL tail to get from the API (for example,
#' `"{season}/circuits.json?limit=40"` is called from `load_circuits()`).
#' @keywords internal
#' @return the result of `jsonlite::fromJSON` called on Ergast's return content.
#' Further processing is performed by specific functions
get_ergast_content <- function(url) {
  # Function Deprecation Warning
  lifecycle::deprecate_soft("at the end of 2024", "get_ergast_content()",
    details = c(
      "i" = "By the end of 2024 the Ergast Motor Racing Database API will be shut down.",
      " " = "This package will update with a replacement when one is available."
    )
  )

  # Function Code

  # note:
  # Throttles at 4 req/sec. Note additional 200 req/hr requested too (http://ergast.com/mrd/terms/)
  # Caches requests at option = 'f1dataR.cache' location, if not 'current', 'last', or 'latest' result requested
  # Automatically retries request up to 5 times. Back-off provided in httr2 documentation
  # Automatically retries at http if https fails after retries.


  ergast_raw <- httr2::request("https://ergast.com/api/f1") %>%
    httr2::req_url_path_append(url) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_user_agent(glue::glue("f1dataR/{ver}", ver = utils::installed.packages()["f1dataR", "Version"])) %>%
    httr2::req_throttle(4 / 1) %>%
    httr2::req_error(is_error = ~FALSE)

  ergast_res <- NULL

  tryCatch(
    {
      ergast_res <- ergast_raw %>%
        httr2::req_perform()
    },
    error = function(e) {
      cli::cli_alert_danger(glue::glue("f1dataR: Error getting data from Ergast:\n{e}", e = e))
    }
  )

  # Restart retries to ergast with http (instead of https)
  # No testing penalty for ergast functioning correct
  # nocov start
  if (is.null(ergast_res) || httr2::resp_is_error(ergast_res) || httr2::resp_body_string(ergast_res) == "Unable to select database") {
    cli::cli_alert_warning("Failure at Ergast with https:// connection. Retrying as http://.")
    tryCatch(
      {
        ergast_res <- ergast_raw %>%
          httr2::req_url("http://ergast.com/api/f1") %>%
          httr2::req_url_path_append(url) %>%
          httr2::req_perform()
      },
      error = function(e) {
        cli::cli_alert_danger(glue::glue("f1dataR: Error getting data from Ergast:\n{e}", e = e))
      }
    )
  }

  if (is.null(ergast_res)) {
    cli::cli_alert_danger("Couldn't connect to Ergast to retrieve data.")
    return(NULL)
  }

  if (httr2::resp_is_error(ergast_res)) {
    cli::cli_alert_danger(glue::glue("Error getting Ergast data, http status code {code}.\n{msg}",
      code = httr2::resp_status(ergast_res),
      msg = httr2::resp_status_desc(ergast_res)
    ))
    return(NULL)
  }

  if (httr2::resp_body_string(ergast_res) == "Unable to select database") {
    cli::cli_alert_danger("Ergast is having database trouble. Please try again at a later time.")
    return(NULL)
  }
  # nocov end

  # else must be ok
  return(jsonlite::fromJSON(httr2::resp_body_string(ergast_res)))
}


#' Get Current Season
#'
#' @description Determines current season by System Date. Note returns the season prior to the current year
#' in January and February
#' @export
#' @return Year (four digit number) representation of current season, as numeric.
get_current_season <- function() {
  return(ifelse(as.numeric(strftime(Sys.Date(), "%m")) < 3,
    as.numeric(strftime(Sys.Date(), "%Y")) - 1,
    as.numeric(strftime(Sys.Date(), "%Y"))
  ))
}


#' Convert Clock time to seconds
#'
#' @description This function converts clock format time (0:00.000) to seconds (0.000s)
#'
#' @param time character string with clock format (0:00.000)
#' @importFrom magrittr "%>%"
#' @return A numeric variable that represents that time in seconds
time_to_sec <- function(time) {
  subfun <- function(x) {
    if (is.na(x)) {
      NA
    } else if (is.numeric(x)) {
      x
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
      reticulate::py_run_string(glue::glue("{session_name}.t0_date", session_name = session_name))
    },
    error = function(e) {
      reticulate::py_run_string(glue::glue("{session_name}.load()", session_name = session_name))
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
        httr2::req_user_agent(glue::glue("f1dataR/{ver}", ver = utils::installed.packages()["f1dataR", "Version"])) %>%
        httr2::req_throttle(4 / 1) %>%
        httr2::req_error(is_error = ~FALSE)
      status <- ff1raw %>%
        httr2::req_perform()
    },
    error = function(e) {
      cli::cli_alert_danger(glue::glue("f1dataR: Error getting data from F1 Live Timing:\n{e}", e = e))
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
#' `f1dataR` (currently requires 3.1.0 or better).
#'
#' This function is a light wrapper around get_fastf1_version()
#'
#' @return Invisibly `TRUE` if not raising an error for unsupported `FastF1` version.
#'
#' @keywords internal
check_ff1_version <- function() {
  version <- get_fastf1_version()
  if (version < "3.1") {
    cli::cli_abort(c("An old version of {.pkg FastF1} is in use. {.pkg f1dataR} requires {.pkg FastF1} version 3.1.0 or newer.",
      x = "Support for older {.pkg FastF1} versions was removed in {.pkg f1dataR} v1.6.0",
      i = "You can update your {.pkg FastF1} installation manually, or by running:",
      " " = "{.code setup_fastf1()}"
    ))
  } else if (version < "3.4") {
    cli::cli_warn(c("An old version of {.pkg FastF1} is in use. {.pkg f1dataR} requires {.pkg FastF1} version 3.4.0 or newer for some functions.",
      x = "Support for older {.pkg FastF1} versions may be removed soon.",
      i = "You can update your {.pkg FastF1} installation manually, or by running:",
      " " = "{.code setup_fastf1()}"
    ))
  } else {
    invisible(TRUE)
  }
}


#' Get current FastF1 version
#'
#' @description
#' Gets the current installed FastF1 version available (via `reticulate`) to the function.
#' Displays a note if significantly out of date.
#' @export
#' @return version as class `package_version`
get_fastf1_version <- function() {
  ver <- reticulate::py_list_packages() %>%
    dplyr::filter(.data$package == "fastf1") %>%
    dplyr::pull("version")
  if (length(ver) == 0) {
    cli::cli_warn("Ensure {.pkg fastf1} Python package is installed.",
      i = "Please run this to install the most recent version:",
      " " = "{.code setup_fastf1()}"
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
  if (!is.na(na_type)) {
    cli::cli_abort(x = "{.arg na_type} must be provided as an actual {.code NA_type_} (for example, {.val NA_character_}).")
  }
  if (!(inherits(data, "data.frame"))) {
    cli::cli_abort(x = "{.arg data} must be provided as a {.code data.frame} or {.code tibble}.")
  }
  if (!(length(column_name) == 1) | !(inherits(column_name, "character"))) {
    cli::cli_abort(x = "{.arg column_name} must be provided as a single {.code character} value.")
  }
  if (!(column_name %in% colnames(data))) {
    data[, column_name] <- na_type
  }
  return(dplyr::as_tibble(data))
}
# nocov start

#' Setup fastf1 connection
#'
#' @description Installs or optionally updates `fastf1` Python package in the current active Python
#' environment/virtualenv/conda env.
#'
#' More information on how to manage complex environment needs can be read in the
#' \href{https://rstudio.github.io/reticulate/articles/python_dependencies.html}{reticulate docs}, and tools for
#' managing virtual environments are documented in  \link[reticulate]{virtualenv-tools} and
#' \link[reticulate]{conda-tools}
#' @param ... Additional parameters to pass to \link[reticulate]{py_install}
#' @param envname Optionally pass an environment name used. Defaults to package default of `f1dataR_env`.
#' @param new_env Whether or not to completely remove and recreate the environment provided in `envname`. This will fix
#' any issues experienced by `fastf1` related to package dependencies.
#' @export
#' @return No return value, called to install or update `fastf1` Python package.
#' @examples
#' \dontrun{
#' # Install fastf1 into the currently active Python environment
#' setup_fastf1()
#'
#' # Reinstall fastf1 and recreate the environment.
#' setup_fastf1(envname = "f1dataR_env", new_env = TRUE)
#' }
setup_fastf1 <- function(..., envname = "f1dataR_env", new_env = identical(envname, "f1dataR_env")) {
  if (new_env && virtualenv_exists(envname)) {
    cli::cli_alert_warning("The Python environment {.var {envname}} is being removed and rebuilt for {.pkg FastF1}f")
    virtualenv_remove(envname)
  }

  cli::cli_alert_info("Installing {.pkg FastF1} in current Python environment: {.var {envname}}.")
  reticulate::py_install("fastf1", envname = envname, ...)
}


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
