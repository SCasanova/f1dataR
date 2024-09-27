test_that("load_constructors works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_constructors"))) {
    unlink(file.path(tempdir(), "tst_load_constructors"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_constructors"))
  dir.create(file.path(tempdir(), "tst_load_constructors"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_constructors"))

  skip_if_no_jolpica()

  constructors <- load_constructors()

  skip_if(is.null(constructors))

  expect_equal(ncol(constructors), 3)
  expect_equal(constructors[1, ]$constructor_id, "adams")
  expect_true(nrow(unique(constructors)) >=212)
})

test_that("load_constructors works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_constructors2"))) {
    unlink(file.path(tempdir(), "tst_load_constructors2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_constructors2"))
  dir.create(file.path(tempdir(), "tst_load_constructors2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_constructors2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_constructors(), "f1dataR: Error getting data from Jolpica")
          expect_null(load_constructors())
        })
      })
    })
  }
})
