test_that("check_ff1_auth passes when credentials are set", {
  withr::local_envvar(F1_USERNAME = "a@b.com", F1_PASSWORD = "pw")
  expect_invisible(check_ff1_auth())
  expect_true(check_ff1_auth())
})

test_that("check_ff1_auth errors non-interactively when missing", {
  withr::local_envvar(F1_USERNAME = "a@b.com", F1_PASSWORD = "")
  local_mocked_bindings(is_interactive = function() FALSE, .package = "rlang")
  expect_error(check_ff1_auth(), "requires authentication")
})

test_that("check_ff1_auth prompts interactively when missing", {
  withr::local_envvar(F1_USERNAME = "", F1_PASSWORD = "")
  local_mocked_bindings(is_interactive = function() TRUE, .package = "rlang")
  called <- FALSE
  local_mocked_bindings(set_f1_auth = function(...) called <<- TRUE)
  suppressMessages(check_ff1_auth())
  expect_true(called)
})

test_that("set_f1_auth sets env vars without persisting by default", {
  renv <- withr::local_tempfile()
  withr::local_envvar(F1_USERNAME = "", F1_PASSWORD = "", R_ENVIRON_USER = renv)
  local_mocked_bindings(is_interactive = function() FALSE, .package = "rlang")
  expect_error(set_f1_auth(), "non-interactive")
  suppressMessages(set_f1_auth("a@b.com", "pw"))
  expect_equal(Sys.getenv("F1_USERNAME"), "a@b.com")
  expect_equal(Sys.getenv("F1_PASSWORD"), "pw")
  expect_false(file.exists(renv))
})

test_that("set_f1_auth persist upserts .Renviron and preserves other lines", {
  renv <- withr::local_tempfile()
  writeLines(c("FOO=bar", "F1_USERNAME=old"), renv)
  withr::local_envvar(F1_USERNAME = "", F1_PASSWORD = "", R_ENVIRON_USER = renv)
  local_mocked_bindings(is_interactive = function() FALSE, .package = "rlang")
  suppressMessages(set_f1_auth("a@b.com", "p\"w", persist = TRUE))
  suppressMessages(set_f1_auth("a@b.com", "p\"w", persist = TRUE))
  lines <- readLines(renv)
  expect_equal(
    lines,
    c("FOO=bar", "F1_USERNAME=\"a@b.com\"", "F1_PASSWORD=\"p\\\"w\"")
  )
})

test_that("set_f1_auth rejects empty values", {
  withr::local_envvar(F1_USERNAME = "", F1_PASSWORD = "")
  local_mocked_bindings(is_interactive = function() FALSE, .package = "rlang")
  expect_error(set_f1_auth("", "pw"), "non-empty")
})
