test_that("load_ciruits works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_circuits"))) {
    unlink(file.path(tempdir(), "tst_load_circuits"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_circuits"))
  dir.create(file.path(tempdir(), "tst_load_circuits"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_circuits"))

  skip_if_no_jolpica()

  circuits_2021 <- load_circuits(2021)

  skip_if(is.null(circuits_2021))

  expect_equal(nrow(circuits_2021), 21)
  expect_equal(circuits_2021$circuit_id[3], "baku")
  expect_equal(circuits_2021$locality[1], "Austin")

  expect_error(load_circuits(3050), "`season` must be between 1950 and *")
})

test_that("load_circuits works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_circuits2"))) {
    unlink(file.path(tempdir(), "tst_load_circuits2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_circuits2"))
  dir.create(file.path(tempdir(), "tst_load_circuits2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_circuits2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_circuits(2021), "f1dataR: Error getting data from Jolpica")
          expect_null(load_circuits(2021))
        })
      })
    })
  }
})
