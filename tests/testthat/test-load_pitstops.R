test_that("load_pitstops works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_pitstops"))) {
    unlink(file.path(tempdir(), "tst_load_pitstops"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_pitstops"))
  dir.create(file.path(tempdir(), "tst_load_pitstops"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_pitstops"))

  skip_if_no_jolpica()

  pitstop_2021_1 <- load_pitstops(2021, 1)

  skip_if(is.null(pitstop_2021_1))

  expect_equal(nrow(pitstop_2021_1), 40)
  expect_equal(pitstop_2021_1$driver_id[1], "perez")
  expect_equal(pitstop_2021_1$stop[2], "1")

  expect_error(load_pitstops(3050, 1), "`season` must be between 2011 and *")

  expect_error(load_pitstops(2021, race = 1))
})

test_that("load_pitstops works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_pitstops2"))) {
    unlink(file.path(tempdir(), "tst_load_pitstops2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_pitstops2"))
  dir.create(file.path(tempdir(), "tst_load_pitstops2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_pitstops2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_pitstops(2021, 1), "f1dataR: Error getting data from Jolpica")
          expect_null(load_pitstops(2021, 1))
        })
      })
    })
  }
})
