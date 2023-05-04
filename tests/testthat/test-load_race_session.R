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

  # test cache is empty fastf1 >= 3.0.0 *always* cachces
  # load_race_session("session", season=2022, race = 1, session = "R", cache=FALSE)
  # expect_false(file.exists(file.path(getwd(), "tst_session", "fastf1_http_cache.sqlite")))

  # test with all parameters but session provided
  expect_invisible(load_race_session("session", season=2022, race = 1))#, verbose = F))
  # validate the cache is there now
  expect_true(file.exists(file.path(getwd(), "tst_session", "fastf1_http_cache.sqlite")))

  # test without race provided - loads from cache
  expect_invisible(load_race_session("session", season=2022, session = "R"))#, verbose = F))

  # test without season provided - default is current year assigned at argument
  session1<-load_race_session("session", session = "R")#, verbose = F)
  # likewise, load it with 'current'
  session2<-load_race_session('session', session = "R", season="current")#, verbose = F)
  expect_equal(session1$api_path, session2$api_path)

  #verify character and numeric race can draw the same endpoint
  session1<-load_race_session('session', season = 2022, race = 1, session = "R")#, verbose = F)
  session2<-load_race_session('session', season = 2022, race = 'Bahrain', session = "R")#, verbose = F)
  expect_equal(session1$api_path, session2$api_path)


  expect_error(load_race_session(season = 2017),
               "Year must be between 2018 and *")
  expect_error(load_race_session(session = "ZZZ"),
               'Session must be one of "FP1", "FP2", "FP3", "Q", "S", or "R"')
  expect_error(load_race_session('session', season = 2022, race = 1, session = "R", log_level = "ZZZ"))
  #expect_message(load_race_session('session', season = 2022, race = 1, session = "R", log_level = 'INFO'),
  #               regexp = NULL) # This type of check is set up to later possibly handle verbose = FALSE/TRUE option tests


})
