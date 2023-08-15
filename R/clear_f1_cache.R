#' Clear f1fastR Cache
#'
#' @description Clears the cache for f1dataR telemetry.
#' Note that the cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' but the default is the current working directory.
#'
#' @import reticulate
#' @return No return value, called to erase cached data
#' @examples
#' \dontrun{
#' clear_f1_cache()
#' }
#' @export
clear_f1_cache <- function() {
  if (reticulate::py_available(initialize = TRUE)) {
    if ("fastf1" %in% reticulate::py_list_packages()$package) {
      reticulate::py_run_string("import fastf1")
      if (get_fastf1_version() >= 3) {
        reticulate::py_run_string(glue::glue("fastf1.Cache.clear_cache('{cache_dir}')",
          cache_dir = normalizePath(getOption("f1dataR.cache"))
        ))
      } else {
        reticulate::py_run_string(glue::glue("fastf1.api.Cache.clear_cache('{cache_dir}')",
          cache_dir = normalizePath(getOption("f1dataR.cache"))
        ))
      }
    }
  }

  memoise::forget(f1dataR::load_circuits)
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
