
.onLoad <- function(libname, pkgname) {
  reticulate::configure_environment(pkgname)
}

.onAttach <- function(libname, pkgname) {
  #Load preexisting session/user options
  op <- options()

  #Make our own lost of options
  op_package <- list(f1dataR.cache = getwd())

  #IFF our options aren't already set, we'll include those in the new options to write
  toset <- !(names(op_package) %in% names(op))
  if (any(toset)) {
    options(op_package[toset])
  }

  invisible()
}
