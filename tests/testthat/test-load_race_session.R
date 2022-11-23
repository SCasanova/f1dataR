# helper function to skip tests if we don't have the fastf1 module
skip_if_no_ff1 <- function() {
  have_ff1 <- reticulate::py_module_available("fastf1")
  if (!have_ff1)
    skip("fastf1 not available for testing")
}

test_that("Load Session Works", {
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

  #Tests

  # Should change to having 'TRUE' returned invisibly from load_race_session
  # Then can validate expect_true for success instead of just having nothing return

  # test cache is empty
  load_race_session("session", season=2022, race = 1, session = "R", cache=FALSE)
  expect_false(file.exists(file.path(getwd(), "tst_session", "fastf1_http_cache.sqlite")))

  # test with all parameters but session provided
  expect_invisible(load_race_session("session", season=2022, race = 1))
  # validate the cache is there now
  expect_true(file.exists(file.path(getwd(), "tst_session", "fastf1_http_cache.sqlite")))

  # test without race provided - loads from cache
  expect_invisible(load_race_session("session", season=2022, session = "R"))
  # test without season provided (also no race provided, in case mid-season)
  # DOESN't WORK YET
  #expect_invisible(load_race_session("session", session = "R"))

  expect_error(load_race_session(season = 2017),
               "Year must be between 1950 and *")
  expect_error(load_race_session(session = "ZZZ"),
               'Session must be one of "FP1", "FP2", "FP3", "Q", "S", or "R"')


})
