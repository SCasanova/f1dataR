
.onLoad <- function(libname,pkgname){
  reticulate::py_install("fastf1", method = 'auto', pip = T)
  reticulate::import("fastf1", delay_load = TRUE)
}
