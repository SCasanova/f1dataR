test_that("aesthetics works", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_aesthetics"))) {
    unlink(file.path(tempdir(), "tst_aesthetics"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_aesthetics"))
  dir.create(file.path(tempdir(), "tst_aesthetics"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_aesthetics"))

  # Tests

  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.4") {
    expect_error(
      session <- get_driver_style(driver = "ALO", season = 2024, round = 1),
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

  expect_error(get_driver_style(c("Lando Norris", "Max Verstappen"), 2024, 1),
    "`driver` must be a character vector of length one.",
    fixed = TRUE
  )
  expect_error(get_driver_style("q", 2024, 1), "Error running FastF1 code:")

  expect_error(get_driver_color(c("Lando Norris", "Max Verstappen"), 2024, 1),
    "`driver` must be a character vector of length one.",
    fixed = TRUE
  )
  expect_error(get_driver_color("q", 2024, 1), "Error running FastF1 code:")

  expect_error(get_team_color(c("Red Bull", "Mercedes"), 2024, 1),
    "`team` must be a character vector of length one.",
    fixed = TRUE
  )
  expect_error(get_team_color("q", 2024, 1), "Error running FastF1 code:")
})

test_that("lookups works", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_lookups"))) {
    unlink(file.path(tempdir(), "tst_lookups"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_lookups"))
  dir.create(file.path(tempdir(), "tst_lookups"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_lookups"))

  # Tests

  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.4") {
    expect_error(
      session <- get_driver_style(driver = "ALO", season = 2024, round = 1),
      "requires FastF1 version 3.4.0"
    )
    skip("Skipping look-ups as FastF1 is out of date.")
  }

  expect_equal(get_driver_abbreviation("Lewis Hamilton", 2024), "HAM")
  expect_equal(get_driver_name("Lewis", 2024), "Lewis Hamilton")
  expect_equal(get_team_by_driver("HAM", 2024), "Mercedes")
  expect_equal(get_team_name("Merc", 2024), "Mercedes")
  expect_equal(get_team_name("Haas", 2024, short = TRUE), "Haas")
  expect_equal(get_drivers_by_team("Mercedes", 2024), c("Lewis Hamilton", "George Russell"))
  dt <- get_session_drivers_and_teams(2024, 1)

  expect_true(is.data.frame(dt))
  expect_equal(nrow(dt), 20)
  expect_equal(names(dt), c("name", "abbreviation", "team"))

  expect_equal(
    get_tire_compounds(2024),
    data.frame(
      compound = c("SOFT", "MEDIUM", "HARD", "INTERMEDIATE", "WET", "UNKNOWN", "TEST-UNKNOWN"),
      color = c("#da291c", "#ffd12e", "#f0f0ec", "#43b02a", "#0067ad", "#00ffff", "#434649")
    )
  )

  expect_error(get_driver_abbreviation(c("Lewis", "George"), 2024),
    "`driver_name` must be a character vector of length one.",
    fixed = TRUE
  )
  expect_error(get_driver_name(c("Lewis", "George"), 2024),
    "`driver_name` must be a character vector of length one.",
    fixed = TRUE
  )
  expect_error(get_team_by_driver(c("Lewis", "George"), 2024),
    "`driver_name` must be a character vector of length one.",
    fixed = TRUE
  )
  expect_error(get_team_name(c("Merc", "Aston"), 2024),
    "`team_name` must be a character vector of length one.",
    fixed = TRUE
  )
  expect_error(get_team_name("Merc", 2024, short = "yes"),
    "`short` must be a single logical value.",
    fixed = TRUE
  )
  expect_error(get_drivers_by_team(c("Merc", "Aston"), 2024),
    "`team_name` must be a character vector of length one.",
    fixed = TRUE
  )

  expect_error(get_driver_abbreviation("q", 2024), "Error running FastF1 code:", fixed = TRUE)
  expect_error(get_driver_name("q", 2024), "Error running FastF1 code:", fixed = TRUE)
  expect_error(get_team_by_driver("q", 2024), "Error running FastF1 code:", fixed = TRUE)
  expect_error(get_team_name("q", 2024), "Error running FastF1 code:", fixed = TRUE)
  expect_error(get_drivers_by_team("q", 2024), "Error running FastF1 code:", fixed = TRUE)
})
