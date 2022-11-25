#' Clear f1fastR Cache
#'
#' Clears the cache for f1dataR telemetry.
#' Note that the cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' but the default is the current working directory.
#' @export

clear_f1_cache <- function(){
  reticulate::py_run_string('import fastf1')
  reticulate::py_run_string(glue::glue('fastf1.api.Cache.clear_cache("{cache_dir}")', cache_dir = getOption('f1dataR.cache')))

  memoise::forget(f1dataR::load_drivers)
  memoise::forget(f1dataR::load_laps)
  memoise::forget(f1dataR::load_pitstops)
  memoise::forget(f1dataR::load_schedule)
  memoise::forget(f1dataR::load_quali)
  memoise::forget(f1dataR::load_results)
  memoise::forget(f1dataR::load_standings)

}
