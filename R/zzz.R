# nocov start
.onLoad <- function(libname, pkgname) {
  reticulate::configure_environment(pkgname)
  # Based on how nflreadr handles caching. Thanks to Tan (github @tanho63) for the suggestions

  memoise_option <- getOption("f1dataR.cache", default = "memory")

  if (!memoise_option %in% c("memory", "filesystem", "off")) {
    if (!dir.exists(normalizePath(memoise_option, mustWork = FALSE))) {
      cli::cli_alert_warning("Option 'f1dataR.cache' was set to {memoise_option}.
                             It should be one of c('memory', 'filesystem', 'off') or a valid/existing path.
                             Reverting to 'memory'.")
      memoise_option <- "memory"
      options("f1dataR.cache" = "memory")
    }
  }

  if (!memoise_option %in% c("memory", "off")) {
    # memoise_option could be a valid dir or the string 'filepath'. If the latter, create a user_cache_dir
    if (memoise_option == "filesystem") {
      cache_dir <- rappdirs::user_cache_dir(appname = "f1dataR")
      dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

      # set the cachedir to our new location for fastf1 caching too
      options("f1dataR.cache" = cache_dir)
    }
    cache <- cachem::cache_disk(dir = memoise_option)
  } else if (memoise_option == "memory") {
    cache <- cachem::cache_mem()
  }

  if (memoise_option != "off") {
    # 86400 s is 24h
    assign(
      x = "load_circuits",
      value = memoise::memoise(load_circuits, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_constructors",
      value = memoise::memoise(load_constructors, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_driver_telemetry",
      value = memoise::memoise(load_driver_telemetry, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_drivers",
      value = memoise::memoise(load_drivers, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_laps",
      value = memoise::memoise(load_laps, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_pitstops",
      value = memoise::memoise(load_pitstops, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_quali",
      value = memoise::memoise(load_quali, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_results",
      value = memoise::memoise(load_results, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_schedule",
      value = memoise::memoise(load_schedule, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_session_laps",
      value = memoise::memoise(load_session_laps, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_sprint",
      value = memoise::memoise(load_sprint, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "load_standings",
      value = memoise::memoise(load_standings, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
    assign(
      x = "plot_fastest",
      value = memoise::memoise(plot_fastest, ~ memoise::timeout(86400), cache = cache),
      envir = rlang::ns_env("f1dataR")
    )
  }
}


.onAttach <- function(libname, pkgname) {
  # default to memory cache if not set
  memoise_option <- getOption("f1dataR.cache")

  if (is.null(memoise_option)) {
    memoise_option <- "memory"
    options("f1dataR.cache" = "memory")
  }

  if (!memoise_option %in% c("memory", "filesystem", "off") && !dir.exists(normalizePath(memoise_option, mustWork = FALSE))) {
    packageStartupMessage(
      "Note: f1dataR.cache is set to '",
      memoise_option,
      "' and should be one of c('memory','filesystem', 'off') or a filepath. \n",
      "Defaulting to 'memory'."
    )
    options("f1dataR.cache" = "memory")
  }

  if (memoise_option != "off") {
    packageStartupMessage(
      "Note: f1dataR will cache for up to 24 hours, \n",
      "or until the end of the R session."
    )
  } else {
    packageStartupMessage(
      "Note: f1dataR.cache is set to 'off' \n",
      "Session specific FastF1 functions will still cache to discardable temporary directory."
    )
  }
}
