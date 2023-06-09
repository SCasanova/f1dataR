test_that("Drivers Load works", {
  drivers_2021_1<-.load_drivers(2021)

  expect_equal(nrow(drivers_2021_1), 21)
  expect_equal(drivers_2021_1$driver_id[2], "bottas")
  expect_equal(drivers_2021_1$code[1], "ALO")

  drivers_2021_1_mem<-load_drivers(2021)
  expect_identical(drivers_2021_1, drivers_2021_1_mem)

  drivers_1999<-load_drivers(1999)
  expect_equal(nrow(drivers_1999), 24)
  expect_equal(drivers_1999$driver_id[1], 'alesi')

  expect_error(load_drivers(3050), "Year must be between 1950 and *")
})
