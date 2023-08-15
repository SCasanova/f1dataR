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
