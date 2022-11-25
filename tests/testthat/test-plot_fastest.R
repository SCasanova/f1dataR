# helper function to skip tests if we don't have the fastf1 module
skip_if_no_ff1 <- function() {
  have_ff1 <- reticulate::py_module_available("fastf1")
  if (!have_ff1)
    skip("fastf1 not available for testing")
}

test_that("graphics work", {
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if(dir.exists(file.path(getwd(), "tst_graphics"))){
    unlink(file.path(getwd(), "tst_graphics"), recursive = T, force = T)
  }
  withr::local_file(file.path(getwd(), "tst_graphics"))
  dir.create(file.path(getwd(), "tst_graphics"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_graphics"))
  withr::local_seed(1234)

  # Snapshot Tests of graphics
  vdiffr::expect_doppelganger("fastest-gear", plot_fastest(2022, 1, "R", "HAM", "gear"))
  vdiffr::expect_doppelganger("fastest-speed", plot_fastest(2022, 1, "R", "HAM", "speed"))
})
