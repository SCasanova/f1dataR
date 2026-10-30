# Generates the pickled FastF1 sessions used to mock FastF1 in tests.
# Requires real F1 credentials and network access; run manually, never in CI:
#   Rscript data-raw/generate_mock_fastf1.R
# Credentials are read from F1_USERNAME / F1_PASSWORD, as for the package itself.

library(reticulate)
py_require(c("fastf1>=3.9.0", "pandas"))

if (!nzchar(Sys.getenv("F1_USERNAME")) || !nzchar(Sys.getenv("F1_PASSWORD"))) {
  stop("Set F1_USERNAME and F1_PASSWORD before generating mock data.")
}

out_dir <- normalizePath(
  file.path("tests", "testthat", "fixtures", "fastf1"),
  mustWork = FALSE
)
cache_dir <- file.path(tempdir(), "f1_mock_cache")

sys <- import("sys")
sys$argv <- list("generate_mock_fastf1.py", out_dir, cache_dir)
py_run_file(file.path("data-raw", "generate_mock_fastf1.py"))
