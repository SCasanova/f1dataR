test_that("Pitstop Load works", {
  pitstop_2021_1<-.load_pitstops(2021, 1)

  expect_equal(nrow(pitstop_2021_1), 40)
  expect_equal(pitstop_2021_1$driver_id[1], "perez")
  expect_equal(pitstop_2021_1$stop[2], "1")

  pitstop_2021_1_mem<-load_pitstops(2021, 1)
  expect_identical(pitstop_2021_1, pitstop_2021_1_mem)

  expect_error(load_pitstops(3050, 1), "`season` must be between 2011 and *")

  expect_warning(load_pitstops(2021, race = 1))
})
