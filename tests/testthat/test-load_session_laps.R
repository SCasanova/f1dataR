test_that("load session laps works", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_session_laps"))) {
    unlink(file.path(tempdir(), "tst_session_laps"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_session_laps"))
  dir.create(file.path(tempdir(), "tst_session_laps"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_session_laps"))

  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < '3.1') {
    expect_error(
      laps <- load_session_laps(season = 2022, round = "bahrain"),
      "An old version of FastF1 is in use"
    )
    skip("Skipping load_session_laps tests as FastF1 is out of date.")
  }

  laps <- load_session_laps(season = 2022, round = "bahrain")
  laps2 <- load_session_laps(season = 2022, round = "bahrain", add_weather = TRUE)
  lapsq <- load_session_laps(season = 2022, round = "bahrain", session = "Q")
  lapsqw <- load_session_laps(season = 2022, round = "bahrain", session = "Q", add_weather = TRUE)

  expect_true("tbl" %in% class(laps))
  expect_true(ncol(laps) %in% c(28, 32))
  expect_true(ncol(laps2) %in% c(35, 39))
  expect_equal(laps$time, laps2$time)
  expect_true(!is.na(laps$time[1]))
  expect_equal(nrow(laps), nrow(laps2))
  if (get_fastf1_version() >= '3') {
    expect_true(all(lapsq$session_type %in% c("Q1", "Q2", "Q3")))
    expect_true(all(c("Q1", "Q2", "Q3") %in% unique(lapsq$session_type)))
  }
  expect_true(!is.na(lapsq$time[1]))
  expect_equal(min(lapsq$lap_time, na.rm = TRUE), 90.558)
  expect_equal(nrow(lapsq), nrow(lapsqw))
  expect_equal(min(lapsq$lap_time, na.rm = TRUE), min(lapsqw$lap_time, na.rm = TRUE))
  expect_lt(ncol(lapsq), ncol(lapsqw))
  expect_true("wind_speed" %in% colnames(lapsqw))

  expect_error(load_session_laps(season = 2022, race = "bahrain", session = "Q"))
})
