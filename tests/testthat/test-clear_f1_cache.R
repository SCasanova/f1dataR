test_that("Cache Clearing works for memoised functions to file", {
  # Note: cache clearing for fastf1 is not our responsibility, it's performed
  # by a call to fastf1 itself.

  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_clear_cache"))) {
    unlink(file.path(tempdir(), "tst_clear_cache"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_clear_cache"))
  dir.create(file.path(tempdir(), "tst_clear_cache"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_clear_cache"))

  expect_false(memoise::has_cache(load_schedule)())
  tmp <- load_schedule()
  expect_true(memoise::has_cache(load_schedule)())
  clear_f1_cache()
  expect_false(memoise::has_cache(load_schedule)())
})


test_that("load_ciruits (off cache) works", {
  # Set testing specific parameters - this disposes after the test finishes
  change_cache("off", persist = FALSE)

  ciruits_2021 <- load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuit_id[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")
})


test_that("load_ciruits (memory cache) works", {
  # Set testing specific parameters - this disposes after the test finishes
  change_cache("memory")

  ciruits_2021 <- load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuit_id[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")

  expect_equal(getOption("f1dataR.cache"), "memory")
})


test_that("load_ciruits (bad path cache) works", {
  # Set testing specific parameters - this disposes after the test finishes
  expect_error(change_cache("fakedirectory"), "Attempt to set cache to fakedirectory failed*")
})


test_that("load_ciruits (filesystem cache) works", {
  # Set testing specific parameters - this disposes after the test finishes
  change_cache(cache = "filesystem")

  ciruits_2021 <- load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuit_id[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")
})
