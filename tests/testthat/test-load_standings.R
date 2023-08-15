test_that("load Standings works", {
  if (dir.exists(file.path(tempdir(), "tst_load_standings"))) {
    unlink(file.path(tempdir(), "tst_load_standings"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_load_standings"))
  dir.create(file.path(tempdir(), "tst_load_standings"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_load_standings"))

  standings_2021 <- load_standings(2021)

  expect_equal(nrow(standings_2021), 21)

  standings_2021_constructor <- load_standings(2021, type = "constructor")
  expect_equal(nrow(standings_2021_constructor), 10)

  expect_error(load_standings(3050), "`season` must be between 2003 and *")
  expect_error(load_standings(2012, "last", "bob"), '`type` must be either "driver" or "constructor"')
})
