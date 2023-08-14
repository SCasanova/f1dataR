test_that("Schedule Load works", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_load_schedule"))) {
    unlink(file.path(tempdir(), "tst_load_schedule"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_schedule"))
  dir.create(file.path(tempdir(), "tst_load_schedule"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_schedule"))

  schedule_2021 <- .load_schedule(2021)

  expect_equal(nrow(schedule_2021), 22)
  expect_equal(schedule_2021$season[1], "2021")
  expect_equal(schedule_2021$race_name[2], "Emilia Romagna Grand Prix")

  schedule_2021_mem <- load_schedule(2021)
  expect_identical(schedule_2021, schedule_2021_mem)

  schedule_1999 <- load_schedule(1999)
  expect_equal(nrow(schedule_1999), 16)
  expect_equal(schedule_1999$circuit_id[1], "albert_park")

  expect_error(load_schedule(3050), "`season` must be between 1950 and *")

  schedule_2018 <- load_schedule(2018)
  expect_true(all(is.na(schedule_1999$sprint_date)))
  expect_true(all(is.na(schedule_2018$sprint_date)))
  expect_equal(sum(!is.na(schedule_2021$sprint_date)), 3)
})
