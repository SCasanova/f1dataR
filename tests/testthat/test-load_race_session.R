# helper function to skip tests if we don't have the fastf1 module
skip_if_no_ff1 <- function() {
  have_ff1 <- reticulate::py_module_available("fastf1")
  if (!have_ff1)
    skip("fastf1 not available for testing")
}

test_that("Load Session Works", {
  skip_if_no_ff1()

  #Should change to having 'TRUE' returned invisibly from load_race_session
  #Then can validate expect_true for success instead of just having nothing return

  #test with all parameters provided
  expect_invisible(load_race_session("session", season=2022, race = 22, session = "R"))
  #test with all parameters but session provided
  expect_invisible(load_race_session("session", season=2022, race = 22))
  #test without race provided
  expect_invisible(load_race_session("session", season=2022, session = "R"))
  #test without season provided (also no race provided, in case mid-season)
  #DOESN't WORK YET
  #expect_invisible(load_race_session("session", session = "R"))

  expect_error(load_race_session(season = 2017),
               "Year must be between 1950 and *")
  expect_error(load_race_session(session = "ZZZ"),
               'Session must be one of "FP1", "FP2", "FP3", "Q", "S", or "R"')

  #Cleanup
  unlink("./tests/testthat/2022", recursive = TRUE)
})
