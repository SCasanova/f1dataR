# helper function to skip tests if we don't have the fastf1 module
skip_if_no_ff1 <- function() {
  have_ff1 <- 'fastf1' %in% reticulate::py_list_packages()$package
  if (!have_ff1)
    skip("fastf1 not available for testing")
}

test_that("load session laps works", {
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if(dir.exists(file.path(getwd(), "tst_session"))){
    unlink(file.path(getwd(), "tst_session"), recursive = T, force = T)
  }
  withr::local_file(file.path(getwd(), "tst_session"))
  dir.create(file.path(getwd(), "tst_session"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_session"))


  laps <- load_session_laps(season = 2022, race = 'bahrain')
  laps2 <- load_session_laps(season = 2022, race = 'bahrain', add_weather = T)
  lapsq <- load_session_laps(season = 2022, race = 'bahrain', session = 'Q')
  lapsqw <- load_session_laps(season = 2022, race = 'bahrain', session = 'Q', add_weather = TRUE)

  expect_equal(class(laps), 'data.frame')
  expect_true(ncol(laps) %in% c(28,32))
  expect_true(ncol(laps2) %in% c(35, 39))
  expect_equal(laps$Time[1], 3855.422)
  expect_equal(laps$Time, laps2$Time)
  expect_equal(nrow(laps), nrow(laps2))
  expect_true(all(lapsq$SessionType %in% c('Q1', 'Q2', 'Q3')))
  expect_true(all(c('Q1', 'Q2', 'Q3') %in% unique(lapsq$SessionType)))
  expect_equal(lapsq$Time[1], 1404.977)
  expect_equal(min(lapsq$LapTime, na.rm = TRUE), 90.558)
  expect_equal(nrow(lapsq), nrow(lapsqw))
  expect_equal(min(lapsq$LapTime, na.rm = TRUE), min(lapsqw$LapTime, na.rm = TRUE))

})
