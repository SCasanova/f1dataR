test_that("Lap Load works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(getwd(), "tst_load_laps"))) {
    unlink(file.path(getwd(), "tst_load_laps"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(getwd(), "tst_load_laps"))
  dir.create(file.path(getwd(), "tst_load_laps"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_load_laps"))

  laps_2021_1 <- load_laps(2021, 1)

  expect_equal(nrow(laps_2021_1), 1026)
  expect_equal(laps_2021_1$driver_id[3], "leclerc")
  expect_equal(laps_2021_1$position[1], "1")

  expect_error(load_laps(3050, 3), "`season` must be between 1996 and *")
  expect_warning(load_laps(2021, race = 1))

  # 2021 Spa had very few laps
  laps_short <- load_laps(2021, 12)
  expect_equal(nrow(laps_short), 20)

  # 2021 Monaco had very many laps, this checks >1000 return code
  laps_long <- load_laps(2021, 5)
  expect_equal(nrow(laps_long), 1418)
})
