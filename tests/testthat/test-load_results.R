test_that("load_results works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_results"))) {
    unlink(file.path(tempdir(), "tst_load_results"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_results"))
  dir.create(file.path(tempdir(), "tst_load_results"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_results"))

  skip_if_no_ergast()

  results_2021_1 <- load_results(2021, 1)

  skip_if(is.null(results_2021_1))

  expect_equal(nrow(results_2021_1), 20)
  expect_equal(results_2021_1$driver_id[4], "norris")
  expect_equal(results_2021_1$position[1], "1")

  results_2003 <- load_results(2003, 1)
  expect_equal(nrow(results_2003), 20)
  expect_equal(results_2003$driver_id[2], "montoya")

  # Special Case:
  results_2021_12 <- load_results(2021, 12)
  expect_equal(nrow(results_2021_1), nrow(results_2021_12))
  expect_equal(ncol(results_2003), ncol(results_2021_12))
  expect_true(ncol(results_2021_1) != ncol(results_2021_12))

  expect_error(load_results(3050, 2), "`season` must be between 1950 and *")
})

test_that("load_results works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_results2"))) {
    unlink(file.path(tempdir(), "tst_load_results2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_results2"))
  dir.create(file.path(tempdir(), "tst_load_results2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_results2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_results(2003, 1), "f1dataR: Error getting data from Ergast")
          expect_null(load_results(2003, 1))
        })
      })
    })
  }
})
