# helper function to skip tests if we don't have the fastf1 module
skip_if_no_ff1 <- function() {
  have_ff1 <- reticulate::py_module_available("fastf1")
  if (!have_ff1)
    skip("fastf1 not available for testing")
}

test_that("driver telemetry", {
  skip_if_no_ff1()

  telem <- get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM")
  telem_fast <- get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM", fastest_only = T)

  expect_true(all(telem_fast$Time %in% telem$Time))

  expect_true(nrow(telem) > nrow(telem_fast))
  expect_true(ncol(telem) == ncol(telem_fast))

  expect_message(get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM"),
                 regexp = NULL) # This itype of check is set up to later possibly handle verbose = FALSE/TRUE option tests


  #Cleanup
  unlink("./tests/testthat/2022", recursive = TRUE)
})
