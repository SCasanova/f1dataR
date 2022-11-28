test_that("Lap Load works", {
  laps_2021_1<-.load_laps(2021, 1)

  expect_equal(nrow(laps_2021_1), 1026)
  expect_equal(laps_2021_1$driverId[3], "leclerc")
  expect_equal(laps_2021_1$position[1], "1")

  laps_2021_1_mem<-load_laps(2021, 1)
  expect_identical(laps_2021_1, laps_2021_1_mem)

  expect_error(load_laps(3050, 3), "Year must be between 1996 and *")
})