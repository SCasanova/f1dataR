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
  telem <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM")
  telem_fast <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", fastest_only = T)

  expect_true(nrow(telem) > nrow(telem_fast))
  expect_true(ncol(telem) == ncol(telem_fast))
  if(get_fastf1_version() >= 3){
    expect_equal(telem_fast$session_time[[1]], 3518.641)
    expect_equal(telem_fast$time[[2]], 0.086)
  } else {
    # v3 updated some telemetry calculations, so this handles v2 until it's retired
    expect_equal(telem_fast$session_time[[1]], 3518.595)
    expect_equal(telem_fast$time[[2]], 0.044)
  }

  expect_warning(load_driver_telemetry(season = 2022, race = 'Brazil', session = 'S', driver = 'HAM'))
  expect_warning(get_driver_telemetry(season = 2022, round = 'Brazil', session = 'S', driver = 'HAM'))

})
