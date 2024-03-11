test_that("Drivers Load works", {
  if (dir.exists(file.path(getwd(), "tst_load_drivers"))) {
    unlink(file.path(getwd(), "tst_load_drivers"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(getwd(), "tst_load_drivers"))
  dir.create(file.path(getwd(), "tst_load_drivers"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_load_drivers"))

  drivers_2021 <- load_drivers(2021)

  expect_equal(nrow(drivers_2021), 21)
  expect_equal(drivers_2021$driver_id[2], "bottas")
  expect_equal(drivers_2021$code[1], "ALO")

  drivers_1999 <- load_drivers(1999)
  expect_equal(nrow(drivers_1999), 24)
  expect_equal(drivers_1999$driver_id[1], "alesi")

  expect_error(load_drivers(3050), "`season` must be between 1950 and *")
})

test_that("load_drivers works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_drivers2"))) {
    unlink(file.path(tempdir(), "tst_load_drivers2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_drivers2"))
  dir.create(file.path(tempdir(), "tst_load_drivers2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_drivers2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_drivers(2021), "f1dataR: Error getting data from Ergast")
          expect_null(load_drivers(2021))
        })
      })
    })
  }
})
