test_that(".onLoad's filesystem cache option matches the memoise cache directory", {
  # Regression test: .onLoad() used to create the memoise disk cache in a
  # directory literally named "filesystem" relative to the working directory,
  # while getOption("f1dataR.cache") pointed at the rappdirs location -- the
  # two caches diverged and a stray "filesystem/" directory was left in the CWD.
  skip_on_cran()
  skip_if_not_installed("callr")

  test_wd <- withr::local_tempdir("tst_onload_wd")

  # Source tree (devtools::test) has DESCRIPTION and R/; under R CMD check the
  # tests run against the *installed* package, which has neither, so
  # pkgload::load_all() cannot be used there.
  pkg_path <- Sys.getenv("F1DATAR_PKG_ROOT", unset = NA)
  if (is.na(pkg_path)) {
    candidate <- normalizePath(
      testthat::test_path("..", ".."),
      mustWork = FALSE
    )
    pkg_path <- if (
      file.exists(file.path(candidate, "DESCRIPTION")) &&
        dir.exists(file.path(candidate, "R"))
    ) {
      candidate
    } else {
      NA_character_
    }
  }
  if (!is.na(pkg_path)) {
    skip_if_not_installed("pkgload")
  }

  result <- callr::r(
    function(wd, pkg_path) {
      setwd(wd)
      options(f1dataR.cache = "filesystem")
      if (is.na(pkg_path)) {
        loadNamespace("f1dataR")
      } else {
        pkgload::load_all(pkg_path, quiet = TRUE)
      }
      list(
        option = getOption("f1dataR.cache"),
        relative_dir_exists = dir.exists(file.path(wd, "filesystem")),
        has_cache = memoise::has_cache(f1dataR::load_circuits)
      )
    },
    args = list(wd = test_wd, pkg_path = pkg_path),
    libpath = .libPaths()
  )

  expect_false(result$relative_dir_exists)
  expect_true(dir.exists(result$option))
  expect_false(basename(result$option) == "filesystem")
})
