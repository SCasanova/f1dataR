#' Get Ergast Content
#'
#' @description Gets ergast content and returns the processed json object if
#' no Ergast errors are found. This will automatically fall back from https://
#' to http:// if ergast suffers errors, and will automatically retry up to 5
#' times by each protocol
#'
#' @param url the Ergast URL tail to get from the API (for example,
#' `"current.json?limit=30"` is called from `get_current_season()`).
#' @keywords internal
#' @return the result of `jsonlite::fromJSON` called on ergast's return content.
#' Further processing is performed by specific functions
get_ergast_content <- function(url) {
  # Function Deprecation Warning
  lifecycle::deprecate_soft("at the end of 2024", "get_ergast_content()",
                            details = c("i" = "By the end of 2024 the Ergast Motor Racing Database API will be shut down.",
                                        " " = "This package will update with a replacement when one is available."))

  #Function Code

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

  ergast_raw <- ergast_raw %>%
    httr2::req_perform()

  # Restart retries to ergast with http (instead of https)
  if (httr2::resp_is_error(ergast_raw) || httr2::resp_body_string(ergast_raw) == "Unable to select database") {
    cli::cli_inform("Failure at Ergast with https:// connection. Retrying as http://.")
    ergast_raw <- ergast_raw %>%
      httr2::req_url("http://ergast.com/api/f1") %>%
      httr2::req_url_path_append(url) %>%
      httr2::req_perform()
  }

  if (httr2::resp_is_error(ergast_raw)) {
    cli::cli_abort(glue::glue("Error getting Ergast Data, http status code {code}.\n{msg}",
      code = httr2::resp_status(ergast_raw),
      msg = httr2::resp_status_desc(ergast_raw)
    ))
  }

  if (httr2::resp_body_string(ergast_raw) == "Unable to select database") {
    cli::cli_abort("Ergast is having database trouble. Please try again at a later time.")
  }

  # else must be ok
  return(jsonlite::fromJSON(httr2::resp_body_string(ergast_raw)))
}

#' Get Current Season
#'
#' @description Looks up current season from ergast, fallback to manual determination
#' @export
#' @return Year (four digit number) representation of current season, as numeric.
get_current_season <- function() {
  current_season <- ifelse(as.numeric(strftime(Sys.Date(), "%m")) < 3,
    as.numeric(strftime(Sys.Date(), "%Y")) - 1,
    as.numeric(strftime(Sys.Date(), "%Y"))
  )
  tryCatch(
    {
      url <- "current.json?limit=30"
      data <- get_ergast_content(url)
      current_season <- as.numeric(data$MRData$RaceTable$season)
    },
    error = function(e) {
      cli::cli_inform(glue::glue("f1dataR: Error getting current season from ergast:\n{e}\nFalling back to manually determined 'current' season", e = e))
    }
  )
  return(current_season)
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


#' Get current FastF1 version
#'
#' @description
#' Gets the current installed FastF1 version available (via `reticulate`) to the function.
#' Displays a note if significantly out of date.
#' @export
#' @return integer for major version number (or NA if any error )
get_fastf1_version <- function() {
  ver <- reticulate::py_list_packages() %>%
    dplyr::filter(.data$package == "fastf1") %>%
    dplyr::pull("version")
  if (length(ver) == 0) {
    cli::cli_warn("Ensure {.pkg fastf1} Python package is installed.\nPlease run this to install the most recent version:\n{.code setup_fastf1()}")
    return(NA)
  }
  major <- as.integer(unlist(strsplit(ver, ".", fixed = T))[1])
  minor <- as.integer(unlist(strsplit(ver, ".", fixed = T))[2])
  if (major < 3 | (major == 3 & minor < 1)) {
    lifecycle::deprecate_warn("1.4.1",
      what = I("fastf1 version < 3.1"), with = I("fastf1 version >= 3.1"),
      details = c("Hard deprecation will occur between 2023 and 2024 F1 seasons")
    )
    cli::cli_inform("The Python package {.pgk fastf1} was updated to v3 recently.\nPlease update the version on your system by running:\n{.code setup_fastf1(newenv = TRUE)}\nFuture versions of {.pkg f1dataR} may not support {.pkg fastf1<3.0.0}.")
  }
  return(list(major = major, minor = minor))
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
    cli::cli_alert("The Python environment {.var {envname}} is being removed and rebuilt for {.pkg fastf1}f")
    virtualenv_remove(envname)
  }

  cli::cli_inform("Installing {.pkg fastf1} in current Python environment: {.var {envname}}.")
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
