test_that("Load Session (file cached) Works", {
  testthat::skip_if_offline("formula1.com")
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_session"))) {
    unlink(file.path(tempdir(), "tst_session"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_session"))
  dir.create(file.path(tempdir(), "tst_session"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_session"))

  # Tests

  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.1") {
    expect_error(
      session <- load_race_session(season = 2022, round = 1),
      "An old version of FastF1 is in use"
    )
    skip("Skipping load_race_session as FastF1 is out of date.")
  }

  # test with all parameters but session provided
  expect_invisible(load_race_session(season = 2022, round = 1))
  # validate the cache is there now
  expect_true(file.exists(file.path(tempdir(), "tst_session", "fastf1_http_cache.sqlite")))

  # test without race provided - loads from cache
  expect_invisible(load_race_session(season = 2022, session = "R"))

  # test without season provided - default is current year assigned at argument
  session1 <- load_race_session(session = "R")
  # likewise, load it with 'current'
  session2 <- load_race_session(session = "R", season = "current")
  expect_equal(session1$api_path, session2$api_path)

  # verify character and numeric race can draw the same endpoint
  session1 <- load_race_session(season = 2022, round = 1, session = "R")
  session2 <- load_race_session(season = 2022, round = "Bahrain", session = "R")
  expect_equal(session1$api_path, session2$api_path)
  expect_equal(session1$event$OfficialEventName, "FORMULA 1 GULF AIR BAHRAIN GRAND PRIX 2022")

  expect_error(
    load_race_session(season = 2017),
    "`season` must be between 2018 and *"
  )
  expect_error(
    load_race_session(session = "ZZZ"),
    '`session` must be one of "FP1", "FP2", "FP3", "Q", "SQ", "SS", "S", or "R"'
  )
  expect_error(load_race_session(season = 2022, round = 1, session = "R", log_level = "ZZZ"))

  expect_error(load_race_session(season = 2022, race = "Bahrain", session = "R"))

  expect_message(
    load_race_session(season = 2022, round = 1, session = "R", log_level = "INFO"),
    "The first time a session is loaded, some time is required. Please*"
  )
})

test_that("Load Session (memory cached) Works", {
  # Most tests run in the (file cached) version

  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  withr::local_options(f1dataR.cache = "memory")

  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.1") {
    expect_error(
      session <- load_race_session(season = 2022, round = 1),
      "An old version of FastF1 is in use"
    )
    skip("Skipping load_race_session (memory cache) test as FastF1 is out of date.")
  }

  session1 <- load_race_session(season = 2022, round = 1, session = "R")
  expect_equal(session1$event$OfficialEventName, "FORMULA 1 GULF AIR BAHRAIN GRAND PRIX 2022")
})

test_that("Load Session works without internet", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_session2"))) {
    unlink(file.path(tempdir(), "tst_session2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_session2"))
  dir.create(file.path(tempdir(), "tst_session2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_session2"))

  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.1") {
    skip("Skipping load_race_session (no internet) test as FastF1 is out of date.")
  }

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_race_session(season = 2022, round = 1), "f1dataR: Can't connect to F1 Live Timing for FastF1 data download")
          expect_null(load_race_session(season = 2022, round = 1))
        })
      })
    })
  }
})
