test_that("load_ciruits works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_circuits"))) {
    unlink(file.path(tempdir(), "tst_load_circuits"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_circuits"))
  dir.create(file.path(tempdir(), "tst_load_circuits"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_circuits"))

  ciruits_2021 <- .load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuit_id[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")

  circuits_2021_mem <- load_circuits(2021)
  expect_identical(ciruits_2021, circuits_2021_mem)

  expect_error(load_circuits(3050), "`season` must be between 1950 and *")
})
