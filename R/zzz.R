
.onLoad <- function(libname,pkgname){
  if(!reticulate::py_module_available('fastf1'))
    reticulate::py_install("fastf1", method = 'auto', pip = T)
  # reticulate::import("fastf1", delay_load = TRUE)
}
