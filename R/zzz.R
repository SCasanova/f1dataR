
.onLoad <- function(libname,pkgname){
  reticulate::py_install("fastf1", method = 'auto', conda = 'auto')
  reticulate::import("fastf1", delay_load = TRUE)
}
