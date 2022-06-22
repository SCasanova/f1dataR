#' Clear f1fastR Cache
#'
#' Clears the cache for f1dataR telemetry.
#' @export

clear_f1_cache <- function(){
  reticulate::py_run_string(glue::glue('fastf1.api.Cache.clear_cache("{cache_dir}")',cache_dir = getwd()))
  memoise::forget(f1dataR::load_drivers)
  memoise::forget(f1dataR::load_laps)
  memoise::forget(f1dataR::load_pitstops)
  memoise::forget(f1dataR::load_schedule)
}
