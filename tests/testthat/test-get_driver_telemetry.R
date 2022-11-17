test_that("driver telemetry", {
  telem <- get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM")
  telem_fast <- get_driver_telemetry(season = 2022, race = "Brazil", session = "S", driver = "HAM")
})
