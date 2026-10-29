test_that("load circuit details works", {
  testthat::skip_if_offline("livetiming.formula1.com")
  skip_if_no_py()
  skip_if_no_ff1()
  skip_if_no_fastf1_creds()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_circuit_details"))) {
    unlink(file.path(tempdir(), "tst_circuit_details"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_circuit_details"))
  dir.create(file.path(tempdir(), "tst_circuit_details"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_circuit_details"))

  # Ensure failure if old ff1, then skip
  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.9.0") {
    expect_error(
      circuit_details <- load_circuit_details(2023, "bahrain"),
      "Skipping load_race_session as FastF1 is out of date."
    )
    skip("Skipping load_circuit_details tests as FastF1 is out of date.")
  }

  circuit_details <- load_circuit_details(2023, "bahrain")
  expect_type(circuit_details, "list")
  expect_length(circuit_details, 4)

  # Check corners tibble
  expect_named(circuit_details[[1]], c("x", "y", "number", "letter", "angle", "distance"))
  expect_true(is.data.frame(circuit_details[[1]]))
  corners <- circuit_details[[1]]$number

  expect_true(all(corners > 0))
  expect_true(all(corners == as.integer(corners)))

  # Check marshal_post tibble
  expect_named(circuit_details[[2]], c("x", "y", "number", "letter", "angle", "distance"))
  expect_true(is.data.frame(circuit_details[[2]]))

  # Check marshal_sectors tibble
  expect_named(circuit_details[[3]], c("x", "y", "number", "letter", "angle", "distance"))
  expect_true(is.data.frame(circuit_details[[3]]))

  # Check rotation value
  expect_type(circuit_details[[4]], "double")
  expect_true(circuit_details[[4]] >= 0 & circuit_details[[4]] <= 360)
})

test_that("load circuit details works with mocked FastF1", {
  local_mock_fastf1()

  circuit_details <- load_circuit_details(2023, 1)
  expect_type(circuit_details, "list")
  expect_length(circuit_details, 4)
  expect_named(circuit_details[[1]], c("x", "y", "number", "letter", "angle", "distance"))
  expect_true(is.data.frame(circuit_details[[1]]))
  expect_true(all(circuit_details[[1]]$number > 0))
  expect_true(is.data.frame(circuit_details[[2]]))
  expect_true(is.data.frame(circuit_details[[3]]))
  expect_type(circuit_details[[4]], "double")
  expect_true(circuit_details[[4]] >= 0 & circuit_details[[4]] <= 360)
})

test_that("load circuit details returns NULL without network (mocked)", {
  local_mock_fastf1(network = FALSE)
  expect_null(suppressMessages(load_circuit_details(2024, 1)))
})
