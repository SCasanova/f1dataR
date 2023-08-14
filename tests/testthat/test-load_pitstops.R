test_that("Pitstop Load works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(getwd(), "tst_load_pitstops"))) {
    unlink(file.path(getwd(), "tst_load_pitstops"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(getwd(), "tst_load_pitstops"))
  dir.create(file.path(getwd(), "tst_load_pitstops"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_load_pitstops"))

  pitstop_2021_1 <- load_pitstops(2021, 1)

  expect_equal(nrow(pitstop_2021_1), 40)
  expect_equal(pitstop_2021_1$driver_id[1], "perez")
  expect_equal(pitstop_2021_1$stop[2], "1")

  expect_error(load_pitstops(3050, 1), "`season` must be between 2011 and *")

  expect_warning(load_pitstops(2021, race = 1))
})
