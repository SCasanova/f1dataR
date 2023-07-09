test_that("Cache Clearing works for memoised functions", {
  # Note: cache clearing for fastf1 is not our responsibility, it's performed
  # by a call to fastf1 itself.
  expect_false(memoise::has_cache(load_schedule)())
  tmp <- load_schedule()
  expect_true(memoise::has_cache(load_schedule)())
  clear_f1_cache()
  expect_false(memoise::has_cache(load_schedule)())
})
