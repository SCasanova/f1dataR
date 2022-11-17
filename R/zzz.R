
.onLoad <- function(libname,pkgname){
  reticulate::configure_environment(pkgname)

  # This isn't needed after configure_environment is run -
  # it already installs fastf1 based on the requirements in DESCRIPTION
  #
  # if(!reticulate::py_module_available('fastf1'))
  #   reticulate::py_install("fastf1", method = 'auto', pip = T)
  # reticulate::import("fastf1", delay_load = TRUE)
}

.onAttach <- function(libname, pkgname){
  #Load preexisting session/user options
  op <- options()

  #Make our own lost of options
  op.package <- list(f1dataR.cache = getwd())

  #IFF our options aren't already set, we'll include those in the new options to write
  toset <- !(names(op.package) %in% names(op))
  if(any(toset)) {
    options(op.package[toset])
  }

  invisible()
}
