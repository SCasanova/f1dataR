test_that("driver telemetry", {
  testthat::skip_if_offline("livetiming.formula1.com")
  skip_if_no_py()
  skip_if_no_ff1()
  skip_if_no_fastf1_creds()

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
  if (ff1_ver < "3.9.0") {
    expect_error(
      telem <- load_driver_telemetry(
        season = 2023,
        round = "Brazil",
        session = "S",
        driver = "HAM",
        laps = "all"
      ),
      "Skipping load_race_session as FastF1 is out of date."
    )
    skip("Skipping load_driver_telemetry tests as FastF1 is out of date.")
  }

  telem <- load_driver_telemetry(
    season = 2023,
    round = "Brazil",
    session = "S",
    driver = "HAM",
    laps = "all"
  )
  telem_fast <- load_driver_telemetry(
    season = 2023,
    round = "Brazil",
    session = "S",
    driver = "HAM",
    laps = "fastest"
  )

  expect_true(nrow(telem) > nrow(telem_fast))
  expect_true(ncol(telem) == ncol(telem_fast))

  expect_equal(round(telem_fast$session_time[[1]]), round(3517.868))

  telem_lap <- load_driver_telemetry(
    season = 2023,
    round = "Brazil",
    session = "S",
    driver = "HAM",
    laps = 1
  )
  expect_equal(telem_lap$time[[1]], 0)
  expect_equal(telem_lap$speed[[1]], 0)
  expect_error(
    load_driver_telemetry(
      season = 2023,
      round = "Brazil",
      session = "S",
      driver = "HAM",
      laps = 1.5
    ),
    "* must be one of `fastest`, `all` or an integer value"
  )

  expect_error(
    load_driver_telemetry(
      season = 2023,
      round = "Brazil",
      session = "S",
      driver = "HAM",
      fastest_only = TRUE
    ),
    "The `fastest_only` argument of `load_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )

  expect_error(
    load_driver_telemetry(
      season = 2023,
      race = "Brazil",
      session = "S",
      driver = "HAM"
    ),
    "The `race` argument of `load_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )

  expect_error(
    get_driver_telemetry(
      season = 2023,
      round = "Brazil",
      session = "S",
      driver = "HAM"
    ),
    "`get_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )

  expect_error(
    get_driver_telemetry(
      season = 2023,
      race = "Brazil",
      session = "S",
      driver = "HAM",
      fastest_only = TRUE
    ),
    "`get_driver_telemetry\\(\\)` was deprecated in f1dataR 1.4.0 and is now defunct.*"
  )
})

test_that("driver telemetry works with mocked FastF1", {
  local_mock_fastf1()

  telem <- load_driver_telemetry(
    season = 2023,
    round = 1,
    driver = "HAM",
    laps = "all"
  )
  telem_fast <- load_driver_telemetry(
    season = 2023,
    round = 1,
    driver = "HAM",
    laps = "fastest"
  )
  telem_lap <- load_driver_telemetry(
    season = 2023,
    round = 1,
    driver = "HAM",
    laps = 2
  )

  expect_s3_class(telem, "tbl")
  expect_gt(nrow(telem), nrow(telem_fast))
  expect_equal(ncol(telem), ncol(telem_fast))
  expect_true(all(telem$driver_code == "HAM"))
  expect_true(all(
    c("session_time", "speed", "distance", "driver_ahead") %in% colnames(telem)
  ))
  expect_true(is.numeric(telem_fast$session_time))
  expect_gt(nrow(telem_lap), 0)

  expect_error(
    load_driver_telemetry(season = 2023, round = 1, driver = "HAM", laps = 1.5),
    "* must be one of `fastest`, `all` or an integer value"
  )
  expect_error(
    load_driver_telemetry(
      season = 2023,
      round = 1,
      driver = "HAM",
      fastest_only = TRUE
    ),
    "was deprecated in f1dataR 1.4.0"
  )
  expect_error(
    load_driver_telemetry(season = 2023, race = 1, driver = "HAM"),
    "was deprecated in f1dataR 1.4.0"
  )
})

test_that("driver telemetry returns NULL without network (mocked)", {
  local_mock_fastf1(network = FALSE)
  expect_null(suppressMessages(
    load_driver_telemetry(
      season = 2024,
      round = 1,
      driver = "HAM",
      laps = "all"
    )
  ))
})
