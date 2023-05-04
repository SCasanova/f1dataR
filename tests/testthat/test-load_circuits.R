test_that("load_ciruits works", {
  ciruits_2021<-.load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuitId[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")

  circuits_2021_mem<-load_circuits(2021)
  expect_identical(ciruits_2021, circuits_2021_mem)

  expect_error(load_results(3050, 2), "Year must be between 1950 and *")
})