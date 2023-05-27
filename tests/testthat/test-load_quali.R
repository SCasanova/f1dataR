test_that("Quali Load works", {
  quali_2021_1<-.load_quali(2021, 1)

  expect_equal(nrow(quali_2021_1), 20)
  expect_equal(quali_2021_1$driverId[2], "hamilton")
  expect_equal(quali_2021_1$position[1], "1")

  quali_2021_1_mem<-load_quali(2021, 1)
  expect_identical(quali_2021_1, quali_2021_1_mem)

  quali_2004<-load_quali(2004, 1)
  expect_equal(nrow(quali_2004), 20)
  expect_equal(quali_2004$driverId[2], 'barrichello')

  expect_equal(nrow(load_quali(2015, 16)), 20)

  expect_error(load_quali(3050, 2), "Year must be between 2003 and *")
})
