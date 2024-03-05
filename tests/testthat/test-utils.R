test_that("utility functions work", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_utils"))) {
    unlink(file.path(tempdir(), "tst_utils"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_utils"))
  dir.create(file.path(tempdir(), "tst_utils"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_utils"))

  # current season function - also naturally tested in some load_x functions
  expect_true(is.numeric(get_current_season()))
  expect_gte(get_current_season(), 2022)

  # get_ergast_content() is inherently tested in load_x functions too

  # Test add_col_if_absent()
  testdf <- tibble::tibble("a" = 1:5, "b" = letters[1:5])
  testdf2 <- testdf
  testdf2$col1 <- NA
  expect_equal(testdf2, add_col_if_absent(testdf, "col1"))
  expect_equal(testdf, add_col_if_absent(testdf, "a", NA_real_))
  expect_error(add_col_if_absent(testdf, c("col1", "col2")))
  expect_error(add_col_if_absent(testdf, "col1", 0))
  expect_error(add_col_if_absent(list(a = 1:5), "col1", NA_real_))

  # add_col_if_absent is also inherently tested in many load_x functions too

  if (requireNamespace("httptest", quietly = TRUE)) {
    # Test internet failures for get_current_season
    httptest::without_internet({
      expect_gte(get_current_season(), 2022)
    })
  }

  # Test time format changes
  expect_equal(time_to_sec("12.345"), 12.345)
  expect_equal(time_to_sec("1:23.456"), 83.456)
  expect_equal(time_to_sec("12:34:56.789"), 45296.789)
  expect_equal(time_to_sec("12.3456"), 12.3456)
  expect_equal(time_to_sec(12.345), 12.345)

  expect_equal(
    time_to_sec(c("12.345", "1:23.456", "12:34:56.789", "12.3456")),
    c(12.345, 83.456, 45296.789, 12.3456)
  )
})
