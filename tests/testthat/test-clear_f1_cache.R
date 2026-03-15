test_that("Cache Clearing works for memoised functions to file", {
  skip_if_no_jolpica()
  # Note: cache clearing for fastf1 is not our responsibility, it's performed
  # by a call to fastf1 itself.

  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_clear_cache"))) {
    unlink(
      file.path(tempdir(), "tst_clear_cache"),
      recursive = TRUE,
      force = TRUE
    )
  }
  withr::local_file(file.path(tempdir(), "tst_clear_cache"))
  dir.create(file.path(tempdir(), "tst_clear_cache"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_clear_cache"))

  expect_false(memoise::has_cache(load_schedule)())
  vcr::local_cassette("clear_cache")
  tmp <- load_schedule(season = 2025)
  expect_true(memoise::has_cache(load_schedule)(season = 2025))
  clear_f1_cache()
  expect_false(memoise::has_cache(load_schedule)(season = 2025))
})


test_that("load_ciruits (off cache) works", {
  skip_if_no_jolpica()
  # Set testing specific parameters - this disposes after the test finishes
  change_cache("off", persist = FALSE)

  vcr::local_cassette("load_cache")
  ciruits_2021 <- load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuit_id[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")
})


test_that("load_ciruits (memory cache) works", {
  skip_if_no_jolpica()

  # Set testing specific parameters - this disposes after the test finishes
  withr::local_options("f1dataR.cache" = NULL)
  change_cache("memory", persist = TRUE)
  expect_equal(getOption("f1dataR.cache"), "memory")

  vcr::local_cassette("load_cache")
  ciruits_2021 <- load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuit_id[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")
})


test_that("load_ciruits (bad path cache) works", {
  # Set testing specific parameters - this disposes after the test finishes
  expect_error(
    change_cache("fakedirectory"),
    "Attempt to set cache to fakedirectory failed*"
  )
})


test_that("load_ciruits (filesystem cache) works", {
  skip_if_no_jolpica()

  # Set testing specific parameters - this disposes after the test finishes
  withr::local_options("f1dataR.cache" = NULL)
  change_cache(cache = "filesystem")

  vcr::local_cassette("load_cache")
  ciruits_2021 <- load_circuits(2021)

  expect_equal(nrow(ciruits_2021), 21)
  expect_equal(ciruits_2021$circuit_id[3], "baku")
  expect_equal(ciruits_2021$locality[1], "Austin")
})
