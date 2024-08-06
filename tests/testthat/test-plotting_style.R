test_that("aesthetics works", {
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

  driver1 <- get_driver_style(driver = "ALO", season = 2024, round = 1)
  driver2 <- get_driver_style(driver = "ALO", season = 2024, round = "Bahrain")

  expect_equal(driver1, driver2)
  expect_equal(driver1$driver, "ALO")
  expect_equal(names(driver1), c("linestyle", "marker", "color", "driver", "abbreviation"))

  expect_true(grepl("^#[0-9A-Fa-f]{6}$", get_driver_color(driver = "HAM", season = 2024)))
  expect_equal(get_driver_color("HAM", 2024), get_driver_colour("HAM", 2024))

  expect_true(grepl("^#[0-9A-Fa-f]{6}$", get_team_color("Red Bull", 2024)))
  expect_equal(get_team_color("Red Bull", 2024), get_team_colour("Red Bull", 2024))

  colormap <- get_driver_color_map(2024, 1)
  expect_true(is.data.frame(colormap))
  expect_equal(names(colormap), c("abbreviation", "color"))
  expect_equal(nrow(colormap), 20)

  expect_error(get_driver_style(c("Lando Norris", "Max Verstappen"), 2024, 1), "`driver` must be a character vector of length one.", fixed = TRUE)
  expect_error(get_driver_style("q", 2024, 1), "Error running FastF1 code:")

  expect_error(get_driver_color(c("Lando Norris", "Max Verstappen"), 2024, 1), "`driver` must be a character vector of length one.", fixed = TRUE)
  expect_error(get_driver_color("q", 2024, 1), "Error running FastF1 code:")

  expect_error(get_team_color(c("Red Bull", "Mercedes"), 2024, 1), "`team` must be a character vector of length one.", fixed = TRUE)
  expect_error(get_team_color("q", 2024, 1), "Error running FastF1 code:")
})
