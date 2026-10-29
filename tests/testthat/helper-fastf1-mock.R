# Skip tests that need live FastF1 access (real credentials).
skip_if_no_fastf1_creds <- function() {
  if (!nzchar(Sys.getenv("f1_credential"))) {
    testthat::skip(
      "f1_credential environment variable not set; skipping live FastF1 test"
    )
  }
}

# Skip tests that need python + fastf1 + pandas installed (but no credentials)
skip_if_no_fastf1_py <- function() {
  skip_if_no_py()
  if (
    !reticulate::py_module_available("fastf1") ||
      !reticulate::py_module_available("pandas")
  ) {
    testthat::skip("fastf1/pandas not available for testing")
  }
  if (get_fastf1_version() < "3.9.0") {
    testthat::skip("FastF1 is out of date")
  }
}

mock_fastf1_fixture <- function(session_code, season = 2023, round = 1) {
  testthat::test_path(
    "fixtures",
    "fastf1",
    sprintf("session_%s_%s_%s.pkl", season, round, session_code)
  )
}

# Replace the network/auth layer of FastF1 with pickled sessions. All python
# post-processing and R tidying code still runs against the real FastF1 objects.
#   network = FALSE simulates being unable to reach F1 Live Timing.
local_mock_fastf1 <- function(network = TRUE, .env = parent.frame()) {
  skip_if_no_fastf1_py()
  if (
    !file.exists(mock_fastf1_fixture("R")) ||
      !file.exists(mock_fastf1_fixture("Q"))
  ) {
    testthat::skip(
      "Mock FastF1 fixtures not generated; see data-raw/generate_mock_fastf1.R"
    )
  }
  withr::local_options(f1dataR.cache = "memory", .local_envir = .env)

  testthat::local_mocked_bindings(
    check_ff1_auth = function(...) invisible(TRUE),
    check_ff1_network_connection = function(...) network,
    ff1_load_session = function(...) invisible(NULL),
    ff1_get_session = function(obj_name = "session",
                               season,
                               round,
                               session = "R") {
      path <- mock_fastf1_fixture(session)
      if (!file.exists(path)) {
        cli::cli_abort("No mock FastF1 fixture for session {.val {session}}")
      }
      reticulate::py_run_string("import pickle")
      reticulate::py_run_string(sprintf(
        "with open(r'%s', 'rb') as _f:\n    %s = pickle.load(_f)",
        normalizePath(path, winslash = "/"),
        obj_name
      ))
    },
    .env = .env
  )
  invisible(TRUE)
}

# helper function to skip if python isn't available by reticulate
skip_if_no_py <- function() {
  if (!require("reticulate", quietly = TRUE)) {
    testthat::skip("Reticulate unavailable for testing")
  }
  if (!reticulate::py_available(initialize = TRUE)) {
    testthat::skip("Python not available for testing")
  }
}
