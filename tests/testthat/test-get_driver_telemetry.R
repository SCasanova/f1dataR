# helper function to skip tests if we don't have the fastf1 module
skip_if_no_ff1 <- function() {
  have_ff1 <- 'fastf1' %in% reticulate::py_list_packages()$package
  if (!have_ff1)
    skip("fastf1 not available for testing")
}

test_that("driver telemetry", {
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  withr::local_file(file.path(getwd(), "tst_telem"))
  if(dir.exists(file.path(getwd(), "tst_telem"))){
    unlink(file.path(getwd(), "tst_telem"), recursive = T, force = T)
  }
  dir.create(file.path(getwd(), "tst_telem"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_telem"))

  # Tests
  telem <- get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM")
  telem_fast <- get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM", fastest_only = T)

  expect_true(all(telem_fast$Time %in% telem$Time))

  expect_true(nrow(telem) > nrow(telem_fast))
  expect_true(ncol(telem) == ncol(telem_fast))

  # expect_message(get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM"),
  #                regexp = NULL) # This itype of check is set up to later possibly handle verbose = FALSE/TRUE option tests

})
