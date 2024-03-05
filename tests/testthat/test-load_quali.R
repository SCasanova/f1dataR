test_that("Quali Load works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_quali"))) {
    unlink(file.path(tempdir(), "tst_load_quali"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_quali"))
  dir.create(file.path(tempdir(), "tst_load_quali"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_quali"))

  quali_2021_1 <- load_quali(2021, 1)

  expect_equal(nrow(quali_2021_1), 20)
  expect_equal(quali_2021_1$driver_id[2], "hamilton")
  expect_equal(quali_2021_1$position[1], "1")

  quali_2004 <- load_quali(2004, 1)
  expect_equal(nrow(quali_2004), 20)
  expect_equal(quali_2004$driver_id[2], "barrichello")
  expect_false("q2" %in% quali_2004)

  expect_equal(nrow(load_quali(2015, 16)), 20)

  expect_error(load_quali(3050, 2), "`season` must be between 2003 and *")
})
