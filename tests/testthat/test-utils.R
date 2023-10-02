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

  if (require(httptest)) {
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

test_that("setup-fastf1 works", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  withr::local_file(file.path(tempdir(), "tst_setup"))
  if (dir.exists(file.path(tempdir(), "tst_setup"))) {
    unlink(file.path(tempdir(), "tst_setup"), recursive = TRUE, force = TRUE)
  }
  dir.create(file.path(tempdir(), "tst_setup"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_setup"))
  withr::local_envvar(.new = list(
    "WORKON_HOME" = file.path(tempdir(), "tst_setup"),
    "RETICULATE_PYTHON" = NA
  ))
  withr::defer(reticulate::virtualenv_remove(file.path(tempdir(), "tst_setup", "setup_venv"), confirm = FALSE))
  withr::defer(reticulate::virtualenv_remove(file.path(tempdir(), "tst_setup", "setup_venv_old"), confirm = FALSE))

  reticulate::virtualenv_create(file.path(tempdir(), "tst_setup", "setup_venv"))
  reticulate::use_virtualenv("setup_venv")
  expect_false("fastf1" %in% reticulate::py_list_packages(envname = "setup_venv")$package)
  setup_fastf1(envname = "setup_venv")
  expect_true("fastf1" %in% reticulate::py_list_packages(envname = "setup_venv")$package)

  reticulate::virtualenv_create(file.path(tempdir(), "tst_setup", "setup_venv_old"))
  reticulate::use_virtualenv("setup_venv")
  reticulate::py_install("fastf1==2.3.3", envname = "setup_venv_old")
  expect_true("fastf1" %in% reticulate::py_list_packages(envname = "setup_venv_old")$package)
  expect_equal(suppressWarnings(get_fastf1_version("setup_venv_old")), 2)
  setup_fastf1(envname = "setup_venv_old", new_env = TRUE, ignore_installed = TRUE)
  expect_equal(get_fastf1_version("setup_venv_old"), 3)

})
