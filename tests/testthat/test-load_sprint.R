test_that("sprint works", {
  if (dir.exists(file.path(getwd(), "tst_load_sprint"))) {
    unlink(file.path(getwd(), "tst_load_sprint"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(getwd(), "tst_load_sprint"))
  dir.create(file.path(getwd(), "tst_load_sprint"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_load_sprint"))

  # A sprint exists for season = 2021, round = 10
  sprint_2021_10 <- .load_sprint(2021, 10)

  expect_equal(nrow(sprint_2021_10), 20)
  expect_equal(sprint_2021_10$driver_id[3], "bottas")
  expect_equal(sprint_2021_10$position[1], "1")

  sprint_2021_10_mem <- load_sprint(2021, 10)
  expect_identical(sprint_2021_10, sprint_2021_10_mem)

  expect_error(load_sprint(3050, 2), "`season` must be between 2021 and *")

  # A sprint doesn't exist for season = 2021, round = 11
  expect_null(suppressMessages(load_sprint(2021, 11)))
})
