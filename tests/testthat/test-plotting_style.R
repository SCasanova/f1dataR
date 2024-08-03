test_that("driver_style works", {
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
  if (ff1_ver < "3.4") {
    expect_error(
      session <- get_driver_style(driver = "ALO", season = 2023, round = 1),
      "requires FastF1 version 3.4.0"
    )
    skip("Skipping get_driver_style as FastF1 is out of date.")
  }

  driver1 <- get_driver_style(driver = "ALO", season = 2023, round = 1)
  driver2 <- get_driver_style(driver = "ALO", season = 2023, round = "Bahrain")

  expect_equal(driver1, driver2)
  expect_equal(driver1$driver, "ALO")
  expect_equal(names(driver1), c("linestyle", "marker", "color", "driver"))
})
