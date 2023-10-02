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
  telem <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = "all")
  telem_fast <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = "fastest")

  expect_true(nrow(telem) > nrow(telem_fast))
  expect_true(ncol(telem) == ncol(telem_fast))
  if (get_fastf1_version() >= 3) {
    expect_equal(telem_fast$session_time[[1]], 3518.641)
    expect_equal(telem_fast$time[[2]], 0.086)
  } else {
    # v3 updated some telemetry calculations, so this handles v2 until it's retired
    expect_equal(telem_fast$session_time[[1]], 3518.595)
    expect_equal(telem_fast$time[[2]], 0.044)
    expect_error(
      load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = 1),
      "can only be a lap number if using fastf1 v3.0 or higher"
    )
  }
  if (get_fastf1_version() >= 3) {
    telem_lap <- load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = 1)
    expect_equal(telem_lap$time[[1]], 0)
    expect_equal(telem_lap$speed[[1]], 0)
    expect_error(
      load_driver_telemetry(season = 2022, round = "Brazil", session = "S", driver = "HAM", laps = 1.5),
      "* must be one of `fastest`, `all` or an integer value"
    )
  }

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
