test_that("load_sprint works", {
  if (dir.exists(file.path(tempdir(), "tst_load_sprint"))) {
    unlink(file.path(tempdir(), "tst_load_sprint"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_sprint"))
  dir.create(file.path(tempdir(), "tst_load_sprint"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_sprint"))

  skip_if_no_jolpica()

  # A sprint exists for season = 2021, round = 10
  sprint_2021_10 <- load_sprint(2021, 10)

  skip_if(is.null(sprint_2021_10))

  expect_equal(nrow(sprint_2021_10), 20)
  expect_equal(sprint_2021_10$driver_id[3], "bottas")
  expect_equal(sprint_2021_10$position[1], "1")

  sprint_2025_2 <- load_sprint(2025, 2)

  expect_equal(nrow(sprint_2025_2), 20)
  expect_equal(sprint_2025_2$driver_id[1], "hamilton")
  expect_equal(sprint_2025_2$position[1], "1")

  expect_error(load_sprint(3050, 2), "`season` must be between 2021 and *")

  # A sprint doesn't exist for season = 2021, round = 11
  expect_null(suppressMessages(load_sprint(2021, 11)))
})

test_that("load_sprint works without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_sprint2"))) {
    unlink(file.path(tempdir(), "tst_load_sprint2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_sprint2"))
  dir.create(file.path(tempdir(), "tst_load_sprint2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_sprint2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # This will normally print many warnings and errors to the test log, we don't need those (we expect them as
    # a byproduct of the without_internet call
    suppressWarnings({
      suppressMessages({
        httptest2::without_internet({
          expect_message(load_sprint(2021, 10), "f1dataR: Error getting data from Jolpica")
          expect_null(load_sprint(2021, 10))
        })
      })
    })
  }
})
