test_that("utility functions work", {

  #current season function - also naturally tested in some load_x functions
  expect_true(is.numeric(get_current_season()))
  expect_gte(get_current_season(), 2022)

  #get_ergast_content() is inherently tested in load_x functions


})
