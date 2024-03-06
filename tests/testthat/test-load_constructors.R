test_that("constructors loads", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_constructors"))) {
    unlink(file.path(tempdir(), "tst_load_constructors"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_constructors"))
  dir.create(file.path(tempdir(), "tst_load_constructors"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_constructors"))

  constructors <- load_constructors()

  expect_equal(ncol(constructors), 3)
  expect_equal(constructors[1, ]$constructor_id, "adams")
})

test_that("constructors loads without internet", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_constructors2"))) {
    unlink(file.path(tempdir(), "tst_load_constructors2"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_constructors2"))
  dir.create(file.path(tempdir(), "tst_load_constructors2"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_constructors2"))

  clear_cache()

  if (requireNamespace("httptest2", quietly = TRUE)) {
    # Test internet failures for get_current_season
    httptest2::without_internet({
      expect_message(load_constructors(), "f1dataR: Error getting data from Ergast")
      expect_null(load_constructors())
    })
  }
})
