test_that("load Standings works", {
  standings_2021<-.load_standings(2021)


  expect_equal(nrow(standings_2021), 21)

  standings_2021_mem<-load_standings(2021)
  expect_identical(standings_2021, standings_2021_mem)

  standings_2021_constructor<-load_standings(2021, type = 'constructor')
  expect_equal(nrow(standings_2021_constructor), 10)

  expect_error(load_standings(3050), "Year must be between 1950 and *")

})
