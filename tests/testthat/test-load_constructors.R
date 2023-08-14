test_that("constructors loads", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_constructors"))) {
    unlink(file.path(tempdir(), "tst_load_constructors"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_constructors"))
  dir.create(file.path(tempdir(), "tst_load_constructors"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_constructors"))

  constructors <- .load_constructors()

  expect_equal(ncol(constructors), 3)
  expect_identical(constructors, load_constructors())
})
