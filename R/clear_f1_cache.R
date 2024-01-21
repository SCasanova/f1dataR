#' Clear f1dataR Cache
#'
#' @description Clears the cache for f1dataR telemetry and Ergast API results.
#' Note that the cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' but the default is a temporary directory.
#'
#' You can also call the alias `clear_cache()` for the same result
#'
#' @import reticulate
#' @return No return value, called to erase cached data
#' @examples
#' \dontrun{
#' clear_f1_cache()
#' }
#' @export
#' @rdname clear_cache
clear_f1_cache <- function() {
  if (reticulate::py_available(initialize = TRUE)) {
    if ("fastf1" %in% reticulate::py_list_packages()$package) {
      reticulate::py_run_string("import fastf1")
      if (get_fastf1_version()$major >= 3) {
        try(
          reticulate::py_run_string(glue::glue("fastf1.Cache.clear_cache('{cache_dir}')",
            cache_dir = normalizePath(getOption("f1dataR.cache"))
          ))
        )
      } else {
        try(
          reticulate::py_run_string(glue::glue("fastf1.api.Cache.clear_cache('{cache_dir}')",
            cache_dir = normalizePath(getOption("f1dataR.cache"))
          ))
        )
      }
    }
  }

  memoise::forget(f1dataR::load_circuits)
  memoise::forget(f1dataR::load_circuit_details)
  memoise::forget(f1dataR::load_constructors)
  memoise::forget(f1dataR::load_drivers)
  memoise::forget(f1dataR::load_driver_telemetry)
  memoise::forget(f1dataR::load_laps)
  memoise::forget(f1dataR::load_pitstops)
  memoise::forget(f1dataR::load_quali)
  memoise::forget(f1dataR::load_results)
  memoise::forget(f1dataR::load_schedule)
  memoise::forget(f1dataR::load_session_laps)
  memoise::forget(f1dataR::load_sprint)
  memoise::forget(f1dataR::load_standings)

  memoise::forget(f1dataR::get_current_season)
  memoise::forget(f1dataR::plot_fastest)
}


#' @rdname clear_cache
#' @export
clear_cache <- function() {
  # Serves as a more logically named alternative
  clear_f1_cache()
}


#' Change Caching Settings
#'
#' @description Change caching settings for the package. By default, the cache will be
#' set to keep the results of function calls in memory to reduce the number of requests
#' made to online services for the same data. However, if preferred, the cache can be
#' set to a file directory to make the results persist between sessions.
#'
#' This is a particularly good idea if you're using functions like `load_driver_telemetry()`,
#' `load_session_laps()`, `load_race_session()` or `plot_fastest()` as they take
#' significant time and download large amounts of data each time you run the function.
#'
#' If preferred for testing or waiting for data updates on race weekends, you may wish to
#' set the cache to `'off'` instead.
#'
#' Changes to cache can be made for the session (mark the argument `persist` as `FALSE`)
#' or apply to the next session(s) by setting `persist` to `TRUE`
#'
#' @param cache One of `'memory'`, `'filesystem'`, `'off'` or a directory.
#'
#' If the selection is `'filesystem'` the package will automatically write the cache to
#' the operating system's default location for permanent or temporary caches (see `persist`)
#'
#' @param create_dir Whether to create the directory if it doesn't already exist if
#' a path cache directory is provided. By default this doesn't occur for provided
#' cache paths, but will always happen if the cache choice is set to `'filesystem'`.
#'
#' @param persist Whether to make this change permanent (`TRUE`) or a temporary cache
#' change only (default, `FALSE`). Note if you set `cache` to `'off'` and `persist` to
#' `TRUE` the existing cache will be cleared by calling `clear_cache()`.
#'
#' If `filesystem` is chosen for `cache` and `persist` is set to `TRUE`, then a cache
#' directory will be placed in the default location for the operating system. If instead
#' `persist` is set to `FALSE`, then a temporary directory will be used instead, and this
#' will be removed at the end of the session. This essentially has the same effect as
#' having `cache` set to `'memory'`.
#'
#' @return No return, called for side effects
#'
#' @export
#' @examples
#' \dontrun{
#' change_cache("~/f1dataRcache", create_dir = TRUE)
#'
#' change_cache("off", persist = FALSE)
#' }
change_cache <- function(cache = "memory", create_dir = FALSE, persist = FALSE) {
  if (!cache %in% c("memory", "filesystem", "off")) {
    if (create_dir) {
      if (!dir.exists(normalizePath(cache, mustWork = FALSE))) {
        dir.create(normalizePath(cache), recursive = TRUE, showWarnings = TRUE)
      }
    } else if (!dir.exists(normalizePath(cache, mustWork = FALSE))) {
      cli::cli_abort("Attempt to set cache to {cache} failed.
                      Directory does not exist and `create_dir` was set to FALSE.")
    }
  }

  if (cache == "filesystem") {
    if (!persist) {
      cache_dir <- withr::local_tempdir("f1dataR_cache")
    } else {
      cache_dir <- rappdirs::user_cache_dir(appname = "f1dataR")
    }

    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    # set the cachedir to our new location for fastf1 caching too
    cache <- cache_dir
  }

  if (cache == "off" && persist) {
    clear_f1_cache()
  }

  if (persist) {
    options("f1dataR.cache" = cache)
  } else {
    withr::local_options("f1dataR.cache" = cache)
  }
}
