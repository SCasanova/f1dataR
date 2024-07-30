test_that("load circuit details works", {
  testthat::skip_if_offline("formula1.com")
  skip_if_no_py()
  skip_if_no_ff1()

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
  if (ff1_ver < "3.1") {
    expect_error(
      circuit_details <- load_circuit_details(2023, "bahrain"),
      "An old version of FastF1 is in use"
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

test_that("Load Circuit Details works without internet", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  if (dir.exists(file.path(tempdir(), "tst_telem2"))) {
    unlink(file.path(tempdir(), "tst_telem2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_telem2"))
  dir.create(file.path(tempdir(), "tst_telem2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_telem2"))

  ff1_ver <- get_fastf1_version()
  if (ff1_ver < "3.1") {
    skip("Skipping load_circuit_details (no internet) test as FastF1 is out of date.")
  }

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_circuit_details(2023, "bahrain"), "f1dataR: Can't connect to F1 Live Timing for FastF1 data download")
          expect_null(load_circuit_details(2023, "bahrain"))
        })
      })
    })
  }
})
