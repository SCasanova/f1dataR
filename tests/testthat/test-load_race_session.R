test_that("Load Session (file cached) Works", {
  testthat::skip_if_offline("livetiming.formula1.com")
  skip_if_no_py()
  skip_if_no_ff1()
  skip_if_no_fastf1_creds()

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
  if (ff1_ver < "3.9.0") {
    expect_error(
      session <- load_race_session(season = 2023, round = 1),
      "Skipping load_race_session as FastF1 is out of date."
    )
    skip("Skipping load_race_session as FastF1 is out of date.")
  }

  # test with all parameters but session provided
  expect_invisible(load_race_session(season = 2023, round = 1))
  # validate the cache is there now
  expect_true(file.exists(file.path(tempdir(), "tst_session", "fastf1_http_cache.sqlite")))

  # test without race provided - loads from cache
  expect_invisible(load_race_session(season = 2023, session = "R"))

  # test without season provided - default is current year assigned at argument
  session1 <- load_race_session(session = "R")
  # likewise, load it with 'current'
  session2 <- load_race_session(session = "R", season = "current")
  expect_equal(session1$api_path, session2$api_path)

  # verify character and numeric race can draw the same endpoint
  session1 <- load_race_session(season = 2023, round = 1, session = "R")
  session2 <- load_race_session(season = 2023, round = "Bahrain", session = "R")
  expect_equal(session1$api_path, session2$api_path)
  expect_equal(session1$event$OfficialEventName, "FORMULA 1 GULF AIR BAHRAIN GRAND PRIX 2023")

  expect_error(
    load_race_session(season = 2017),
    "`season` must be between 2018 and *"
  )
  expect_error(
    load_race_session(session = "ZZZ"),
    '`session` must be one of "FP1", "FP2", "FP3", "Q", "SQ", "SS", "S", or "R"'
  )
  expect_error(load_race_session(season = 2023, round = 1, session = "R", log_level = "ZZZ"))

  expect_error(load_race_session(season = 2023, race = "Bahrain", session = "R"))

  expect_error(load_race_session(season = 2023, round = 100, session = "R"))

  expect_message(
    load_race_session(season = 2023, round = 1, session = "R", log_level = "INFO"),
    "The first time a session is loaded, some time is required. Please*"
  )
})

test_that("Load Session (memory cached) Works", {
  # Most tests run in the (file cached) version

  skip_if_no_py()
  skip_if_no_ff1()
  skip_if_no_fastf1_creds()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  withr::local_options(f1dataR.cache = "memory")

  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.9.0") {
    expect_error(
      session <- load_race_session(season = 2023, round = 1),
      "Skipping load_race_session as FastF1 is out of date."
    )
    skip("Skipping load_race_session (memory cache) test as FastF1 is out of date.")
  }

  session1 <- load_race_session(season = 2023, round = 1, session = "R")
  expect_equal(session1$event$OfficialEventName, "FORMULA 1 GULF AIR BAHRAIN GRAND PRIX 2023")
})

test_that("Load Session works with mocked FastF1", {
  local_mock_fastf1()

  expect_invisible(load_race_session(season = 2023, round = 1))
  expect_invisible(load_race_session(season = 2023, round = "Bahrain", session = "Q"))
  expect_message(
    load_race_session(season = 2023, round = 1, log_level = "INFO"),
    "The first time a session is loaded, some time is required. Please*"
  )

  expect_error(load_race_session(season = 2017), "`season` must be between 2018 and *")
  expect_error(load_race_session(session = "ZZZ"), '`session` must be one of "FP1"*')
  expect_error(load_race_session(season = 2023, round = 1, log_level = "ZZZ"))
  expect_error(load_race_session(season = 2023, race = "Bahrain"))
})

test_that("Load Session (mocked) returns NULL without network", {
  local_mock_fastf1(network = FALSE)

  expect_message(
    load_race_session(season = 2023, round = 1),
    "f1dataR: Can't connect to F1 Live Timing for FastF1 data download"
  )
  expect_null(suppressMessages(load_race_session(season = 2023, round = 1)))
})

test_that("Load Session (mocked) returns NULL when session data not loaded", {
  local_mock_fastf1()
  testthat::local_mocked_bindings(
    ff1_get_session = function(obj_name = "session", ...) {
      reticulate::py_run_string(glue::glue(
        "class _Unloaded:\n    api_path = 'x'\n    @property\n    def t0_date(self):\n        raise ValueError('not loaded')\n    def load(self):\n        pass\n{obj_name} = _Unloaded()"
      ))
    },
    check_ff1_session_loaded = function(...) invisible(TRUE)
  )
  expect_message(
    out <- load_race_session(season = 2023, round = 1),
    "Error getting data from FastF1"
  )
  expect_null(out)
})
