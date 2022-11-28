test_that("Schedule Load works", {
  schedule_2021<-.load_schedule(2021)


  expect_equal(nrow(schedule_2021), 22)
  expect_equal(schedule_2021$season[1], "2021")
  expect_equal(schedule_2021$race_name[2], "Emilia Romagna Grand Prix")

  schedule_2021_mem<-load_schedule(2021)
  expect_identical(schedule_2021, schedule_2021_mem)

  schedule_1999<-load_schedule(1999)
  expect_equal(nrow(schedule_1999), 16)
  expect_equal(schedule_1999$circuit_id[1], 'albert_park')

  expect_error(load_schedule(3050), "Year must be between 1950 and *")
})
