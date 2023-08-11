#' Get Ergast Content
#'
#' @description Gets ergast content and returns the processed json object if
#' no Ergast errors are found.
#'
#' @param url the complete Ergast URL to get
#' @keywords internal
#' @return the result of `jsonlite::fromJSON` called on ergast's return content

get_ergast_content <- function(url) {

  # note:
  # Throttles at 4 req/sec. Note additional 200 req/hr requested too (http://ergast.com/mrd/terms/)
  # Caches requests at option = 'f1dataR.cache' location
  # Automatically retries request up to 5 times. Backoff provided in httr2 documentation
  # Automatically retries at http if https fails after retries.

  ergast_raw <- httr2::request("https://ergast.com/api/f1") %>%
    httr2::req_url_path_append(url) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_user_agent(glue::glue("f1dataR/{ver}", ver = utils::installed.packages()["f1dataR", "Version"])) %>%
    httr2::req_cache(path = file.path(getOption('f1dataR.cache'), 'f1dataR_http_cache')) %>%
    httr2::req_throttle(4/1) %>%
    httr2::req_error(is_error = ~ FALSE) %>%
    httr2::req_perform()

  # Restart retries to ergast with http (instead of https)
  if(httr2::resp_is_error(ergast_raw) || httr2::resp_body_string(ergast_raw) == "Unable to select database") {
    cli::cli_inform("Failure at Ergast with https:// connection. Retrying as http://.")
    ergast_raw <- ergast_raw %>%
      httr2::req_url("http://ergast.com/api/f1") %>%
      httr2::req_url_path_append(url) %>%
      httr2::req_perform()
  }

  if(httr2::resp_is_error(ergast_raw)) {
    cli::cli_abort(glue::glue("Error getting Ergast Data, http status code {code}.\n{msg}",
                              code = httr2::resp_status(ergast_raw),
                              msg = httr2::resp_status_desc(ergast_raw)))
  }

  if(httr2::resp_body_string(ergast_raw) == "Unable to select database") {
    cli::cli_abort("Ergast is having database trouble. Please try again at a later time.")
  }

  # else must be ok
  return(jsonlite::fromJSON(httr2::resp_body_string(ergast_raw)))
}

#' Get Current Season core
#'
#' @description Looks up current season from ergast, fallback to manual determination
#' @keywords internal
#' @return Year (four digit number) representation of current season, as numeric.

.get_current_season <- function() {
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

#' @inherit .get_current_season title description return
#' @keywords internal
#' @export
#' @examples
#' # Get the current season
#' get_current_season()
get_current_season <- memoise::memoise(.get_current_season)


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
#' @keywords internal
#' @return integer for major version number (or NA if any error )

.get_fastf1_version <- function() {
  ver <- reticulate::py_list_packages() %>%
    dplyr::filter(.data$package == "fastf1") %>%
    dplyr::pull("version")
  if (length(ver) == 0) {
    cli::cli_warn("Ensure fastf1 python package is installed.\nPlease run this to install the most recent version:\nreticulate::py_install('fastf1')")
    return(NA)
  }
  if (as.integer(substr(ver, start = 1, 1)) >= 3) {
    return(3)
  } else if (as.integer(substr(ver, start = 1, 1)) <= 2) {
    cli::cli_inform("The Python package fastf1 was updated to v3 recently.\nPlease update the version on your system by running:\nreticulate::py_install('fastf1')\nFuture versions of f1dataR may not support fastf1 < v3.0.0")
    return(2)
  } else {
    return(NA)
  }
}

#' @inherit .get_fastf1_version title description return
#' @keywords internal
get_fastf1_version <- memoise::memoise(.get_fastf1_version)


#' Setup fastf1 connection
#'
#' @description Set up reticulate using some options from user (or defaults). Helps
#' solve `fastf1` issues - see the Setup FastF1 Connection vignette for more info
#' (run \code{vignette('setup_fastf1', 'f1dataR')}).
#'
#' @param envname a name for the virtualenv or conda environment.
#'
#' For virtualenv, if a name is passed, `reticulate` will use/create the environment in the
#' default location. Alternatively, if providing a full path, `reticulate` will use the specified location.
#' @param conda whether to use conda environments or virtualenvs. Default FALSE (i.e. virtualenv)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # setup fastf1 connection with all defaults
#' setup_fastf1()
#'
#' # setup with a preexisting conda environment, with a specified name
#' setup_fastf1("example_conda_env", conda = TRUE)
#' }
#'
setup_fastf1 <- function(envname = "f1dataRenv", conda = FALSE) {
  conda_exists <- function() {
    tryCatch(
      {
        v <- reticulate::conda_version()
        return(TRUE)
      },
      error = function(e) {
        return(FALSE)
      }
    )
  }
  if (conda == FALSE) {
    if (envname %in% reticulate::virtualenv_list()) {
      reticulate::use_virtualenv(envname)
    } else if (conda_exists() && envname %in% reticulate::conda_list()$name) {
      cli::cli_abort("{.val envname} found in list of conda environments. Did you mean to use that?",
        x = "Run the function again with {.param conda} = `TRUE`"
      )
    } else {
      reticulate::virtualenv_create(envname = envname, packages = c("numpy", "fastf1"))
      reticulate::use_virtualenv(envname)
    }
  } else {
    if (!conda_exists()) {
      cli::cli_abort("Conda is not installed on your system.",
        i = "If you wish to use conda please run {.code reticulate::install_miniconda}."
      )
    }
    if (envname %in% reticulate::conda_list()$name) {
      reticulate::use_condaenv(envname)
    } else if (envname %in% reticulate::virtualenv_list()) {
      cli::cli_abort("{.val {envname}} found in list of virtualenv environments. Did you mean to use that?",
        x = "Run the function again with {.param conda} = `FALSE`"
      )
    } else {
      reticulate::conda_create(envname = envname, packages = c("numpy", "fastf1"))
      reticulate::use_condaenv(envname)
    }
  }
}
