test_that("load_laps works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_laps"))) {
    unlink(file.path(tempdir(), "tst_load_laps"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_laps"))
  dir.create(file.path(tempdir(), "tst_load_laps"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_laps"))

  skip_if_no_jolpica()

  laps_2021_1 <- load_laps(2021, 1)

  skip_if(is.null(laps_2021_1))

  expect_equal(nrow(unique(laps_2021_1)), 1026)
  expect_equal(laps_2021_1$driver_id[3], "leclerc")
  expect_equal(laps_2021_1$position[1], "1")

  expect_equal(laps_2021_1$driver_id[1026], "raikkonen")
  expect_equal(laps_2021_1$position[1026], "11")
  expect_equal(round(laps_2021_1$time_sec[1026]), round(95.96))

  expect_error(load_laps(3050, 3), "`season` must be between 1996 and *")
  expect_error(load_laps(2021, race = 1))

  # 2021 Spa had very few laps
  laps_short <- load_laps(2021, 12)
  expect_equal(nrow(laps_short), 20)

  # 2021 Monaco had very many laps, this checks >1000 return code
  laps_long <- load_laps(2021, 5)
  expect_equal(nrow(laps_long), 1418)
})

test_that("load_laps works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_laps2"))) {
    unlink(file.path(tempdir(), "tst_load_laps2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_laps2"))
  dir.create(file.path(tempdir(), "tst_load_laps2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_laps2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_laps(2021, 1), "f1dataR: Error getting data from Jolpica")
          expect_null(load_laps(2021, 1))
        })
      })
    })
  }
})
