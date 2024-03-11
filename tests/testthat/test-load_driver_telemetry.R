test_that("driver telemetry", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  withr::local_file(file.path(tempdir(), "tst_telem"))
  if (dir.exists(file.path(tempdir(), "tst_telem"))) {
    unlink(file.path(tempdir(), "tst_telem"), recursive = TRUE, force = TRUE)
  }
  dir.create(file.path(tempdir(), "tst_telem"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_telem"))

  # Tests
  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.1") {
    expect_error(
      telem <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = "all"),
      "An old version of FastF1 is in use"
    )
    skip("Skipping load_driver_telemetry tests as FastF1 is out of date.")
  }

  telem <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = "all")
  telem_fast <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = "fastest")

  expect_true(nrow(telem) > nrow(telem_fast))
  expect_true(ncol(telem) == ncol(telem_fast))

  expect_equal(telem_fast$session_time[[1]], 3518.641)
  expect_equal(round(telem_fast$time[[2]], 3), 0.086)

  telem_lap <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = 1)
  expect_equal(telem_lap$time[[1]], 0)
  expect_equal(telem_lap$speed[[1]], 0)
  expect_error(
    load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = 1.5),
    "* must be one of `fastest`, `all` or an integer value"
  )

  expect_error(
    load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", fastest_only = TRUE),
    "The `fastest_only` argument of `load_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )

  expect_error(
    load_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM"),
    "The `race` argument of `load_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )

  expect_error(
    get_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM"),
    "`get_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )

  expect_error(
    get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM", fastest_only = TRUE),
    "`get_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )
})

test_that("Load Driver Telemetry works without internet", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_telem2"))) {
    unlink(file.path(tempdir(), "tst_telem2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_telem2"))
  dir.create(file.path(tempdir(), "tst_telem2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_telem2"))

  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.1") {
    skip("Skipping load_driver_telemetry (no internet) test as FastF1 is out of date.")
  }

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(
            load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = "all"),
            "f1dataR: Can't connect to F1 Live Timing for FastF1 data download"
          )
          expect_null(load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = "all"))
        })
      })
    })
  }
})
