test_that("load_standings works", {
  if (dir.exists(file.path(tempdir(), "tst_load_standings"))) {
    unlink(file.path(tempdir(), "tst_load_standings"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_standings"))
  dir.create(file.path(tempdir(), "tst_load_standings"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_standings"))

  skip_if_no_jolpica()

  standings_2021 <- load_standings(2021)

  skip_if(is.null(standings_2021))

  expect_equal(nrow(standings_2021), 21)

  standings_2021_constructor <- load_standings(2021, type = "constructor")
  expect_equal(nrow(standings_2021_constructor), 10)

  expect_error(load_standings(3050), "`season` must be between 2003 and *")
  expect_error(load_standings(2012, "last", "bob"), '`type` must be either "driver" or "constructor"')
})

test_that("load_standings works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_standings2"))) {
    unlink(file.path(tempdir(), "tst_load_standings2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_standings2"))
  dir.create(file.path(tempdir(), "tst_load_standings2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_standings2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_standings(2021), "f1dataR: Error getting data from Jolpica")
          expect_null(load_standings(2021))
        })
      })
    })
  }
})
