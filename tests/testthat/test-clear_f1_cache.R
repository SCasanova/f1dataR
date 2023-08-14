test_that("Cache Clearing works for memoised functions to file", {
  # Note: cache clearing for fastf1 is not our responsibility, it's performed
  # by a call to fastf1 itself.

  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(getwd(), "tst_clear_cache"))) {
    unlink(file.path(getwd(), "tst_clear_cache"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(getwd(), "tst_clear_cache"))
  dir.create(file.path(getwd(), "tst_clear_cache"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(getwd(), "tst_clear_cache"))

  expect_false(memoise::has_cache(load_schedule)())
  tmp <- load_schedule()
  expect_true(memoise::has_cache(load_schedule)())
  clear_f1_cache()
  expect_false(memoise::has_cache(load_schedule)())
})
