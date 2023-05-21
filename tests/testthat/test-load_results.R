test_that("Results Load works", {
  results_2021_1<-.load_results(2021, 1)

  expect_equal(nrow(results_2021_1), 20)
  expect_equal(results_2021_1$driverId[4], "norris")
  expect_equal(results_2021_1$position[1], "1")

  results_2021_1_mem<-load_results(2021, 1)
  expect_identical(results_2021_1, results_2021_1_mem)

  results_2003<-load_results(2003, 1)
  expect_equal(nrow(results_2003), 20)
  expect_equal(results_2003$driverId[2], 'montoya')

  #Special Case:
  results_2021_12 <- load_results(2021, 12)
  expect_equal(nrow(results_2021_1), nrow(results_2021_12))
  expect_equal(ncol(results_2003), ncol(results_2021_12))
  expect_true(ncol(results_2021_1) != ncol(results_2021_12))

  expect_error(load_results(3050, 2), "Year must be between 1950 and *")
})
