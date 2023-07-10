test_that("utility functions work", {
  # current season function - also naturally tested in some load_x functions
  expect_true(is.numeric(get_current_season()))
  expect_gte(get_current_season(), 2022)

  # get_ergast_content() is inherently tested in load_x functions too

  # Test internet failures for get_current_season
  httptest::without_internet({
    expect_gte(get_current_season(), 2022)
  })

  # Test time format changes
  expect_equal(time_to_sec("12.345"), 12.345)
  expect_equal(time_to_sec("1:23.456"), 83.456)
  expect_equal(time_to_sec("12:34:56.789"), 45296.789)
  expect_equal(time_to_sec("12.3456"), 12.3456)
  expect_equal(time_to_sec(12.345), 12.345)

  expect_equal(time_to_sec(c("12.345", "1:23.456", "12:34:56.789", "12.3456")),
                           c(12.345, 83.456, 45296.789, 12.3456))

})
