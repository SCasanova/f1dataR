.onLoad <- function(libname, pkgname) {
  reticulate::configure_environment(pkgname)
}

.onAttach <- function(libname, pkgname) {
  # Give instructions on how to set up cache directory
  packageStartupMessage(
    'f1dataR cache is set up on a temporary directory. It is recommended to use `options(f1dataR.cache = path/to/dir/)` to set a permanent cache'
    )

  # Load preexisting session/user options
  op <- options()

  # Make our own list of options
  op_package <- list(f1dataR.cache = tempdir())

  # IF our options aren't already set, we'll include those in the new options to write
  toset <- !(names(op_package) %in% names(op))
  if (any(toset)) {
    options(op_package[toset])
  }

  invisible()
}
