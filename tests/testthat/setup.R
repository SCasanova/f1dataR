require(httptest2, quietly = TRUE)


# helper function to skip tests if we don't have the fastf1 module
skip_if_no_ff1 <- function() {
  if (!require("reticulate", quietly = TRUE)) {
    testthat::skip("Reticulate unavailable for testing")
  }
  have_ff1 <- "fastf1" %in% reticulate::py_list_packages()$package
  if (!have_ff1) {
    testthat::skip("fastf1 not available for testing")
  }
}


# helper function to skip tests if we don't have ggplot2
skip_if_no_ggplot2 <- function() {
  if (!require("ggplot2", quietly = TRUE)) {
    testthat::skip("ggplot2 not available for testing")
  }
}


# helper function to skip if python isn't available by reticulate
skip_if_no_py <- function() {
  if (!require("reticulate", quietly = TRUE)) {
    testthat::skip("Reticulate unavailable for testing")
  }
  if (!reticulate::py_available(initialize = TRUE)) {
    testthat::skip("Python not available for testing")
  }
}


# helper function to skip if jolpica isn't working
skip_if_no_jolpica <- function() {
  testthat::skip_if_offline("jolpi.ca") # This will also skip on CRAN
  if (is.null(get_jolpica_content("current/circuits.json?limit=40"))) {
    testthat::skip("No Jolpica connection available for testing")
  }
}
