#' @title Get Aesthetics
#'
#' @description Various aesthetics can be retrieved for a driver or team for a specific session/event.
#'
#'   `get_driver_style()` gets the FastF1 style for a driver for a session -  this includes team colour and line/marker
#'   style which should be reasonably (but not guaranteed) consistent across a season. Based on FastF1's
#'   [get_driver_style](https://docs.fastf1.dev/plotting.html#fastf1.plotting.get_driver_style).
#'
#'   `get_driver_color()` and its alias `get_driver_colour()` return a hexidecimal RGB colour code for a driver at a
#'   given season & race. Note that, in contrast to earlier versions, both drivers for a team will be provided the same
#'   color. Use `get_driver_style()` to develop a unique marker/linestyle for each driver in a team. Data is provided by
#'   the python FastF1 package.
#'
#'   `get_driver_color_mapping()` and its alias `get_driver_colour_mapping()` return a data.frame of driver short-codes
#'   and their hexidecimal colour. Like `get_driver_color()`, both drivers on a team will get the same colour returned.
#'   Data is provided by the python FastF1 package. Requires provision of a specific race event (season/round/session).
#'
#'   `get_team_color()` and its alias `get_team_colour()` return a hexidecimal RGB colour code for a a team at a given
#'   season & race. Data is provided by the python FastF1 package.
#'
#' @param season A season corresponding to the race being referenced for collecting colour/style. Should be a number
#'   from 2018 to current season. Defaults to current season.
#' @param round A round corresponding to the race being referenced for collecting colour/style. Should be a string name
#'   or a number from 1 to the number of rounds in the season and defaults to 1.
#'
#' @return for `get_driver_style()` a named list of graphic parameters for the provided driver, plus the driver
#'   identifier provided and the official abbreviation matched to that driver (names are `linestyle`, `marker`, `color`,
#'   `driver`, `abbreviation`).
#'
#'   for `get_driver_color()` and `get_team_color()`, a hexidecimal RGB color value.
#'
#' @name get_aesthetics
#'
#' @examples
#' if (interactive()) {
#'   # To get a specific season/race, specify them.
#'   get_driver_style(driver = "ALO", season = 2024, round = 3)
#'
#'   # For drivers who haven't moved around recently, get their current season's style:
#'   get_driver_style(driver = "LEC")
#'
#'   # Get all driver abbreviations and colors quickly:
#'   get_driver_color_mapping(season = 2023, round = "Montreal", session = "R")
#'
#'   get_team_color(team = "Alpine", season = 2023, round = 1)
#' }
#'
NULL


#' @rdname get_aesthetics
#' @param driver Driver abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#'
#' @export
get_driver_style <- function(driver, season = get_current_season(), round = 1) {
  # checks
  if (!is.character(driver) | length(driver) != 1) {
    cli::cli_abort("{.var driver} must be a character vector of length one.")
  }

  get_session(season = season, round = round)

  py_string <- paste(
    glue::glue("driverstyle = get_driver_style('{driver}', ['linestyle', 'marker', 'color'], session)", driver = driver),
    glue::glue("abbreviation = get_driver_abbreviation('{driver}', session)", driver = driver),
    sep = "\n"
  )

  reticulate::py_run_string("from fastf1.plotting import get_driver_style, get_driver_abbreviation")
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  driverstyle <- reticulate::py_to_r(reticulate::py_get_item(py_env, "driverstyle"))
  abbreviation <- py_env$abbreviation

  driverstyle$driver <- driver
  driverstyle$abbreviation <- abbreviation

  return(driverstyle)
}


#' @rdname get_aesthetics
#' @export
get_driver_color <- function(driver, season = get_current_season(), round = 1) {
  # checks
  if (!is.character(driver) | length(driver) != 1) {
    cli::cli_abort("{.var driver} must be a character vector of length one.")
  }

  get_session(season = season, round = round)

  py_string <- glue::glue("drivercolor = get_driver_color('{driver}', session)",
    driver = driver
  )

  reticulate::py_run_string("from fastf1.plotting import get_driver_color")

  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )


  drivercolor <- py_env$drivercolor

  return(drivercolor)
}


#' @rdname get_aesthetics
#' @export
get_driver_colour <- function(driver, season = get_current_season(), round = 1) {
  get_driver_color(driver = driver, season = season, round = round)
}


#' @rdname get_aesthetics
#' @param team Team abbreviation or name (FastF1 performs a fuzzy-match to ambiguous strings).
#'
#' @export
get_team_color <- function(team, season = get_current_season(), round = 1) {
  # checks
  if (!is.character(team) | length(team) != 1) {
    cli::cli_abort("{.var team} must be a character vector of length one.")
  }

  # function
  get_session(season = season, round = round)

  py_string <- glue::glue("teamcolor = get_team_color('{team}', session)",
    team = team
  )

  reticulate::py_run_string("from fastf1.plotting import get_team_color")
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  teamcolor <- py_env$teamcolor

  return(teamcolor)
}


#' @rdname get_aesthetics
#' @export
get_team_colour <- function(team, season = get_current_season(), round = 1) {
  get_team_color(team = team, season = season, round = round)
}


#' @rdname get_aesthetics
#' @inheritParams load_race_session
#' @export
get_driver_color_map <- function(season = get_current_season(), round = 1, session = "R") {
  # function
  get_session(season = season, round = round, session = session)

  reticulate::py_run_string("from fastf1.plotting import get_driver_color_mapping")

  tryCatch(
    py_env <- reticulate::py_run_string("colormap = get_driver_color_mapping(session)"),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  colormap <- reticulate::py_to_r(reticulate::py_get_item(py_env, "colormap"))

  colormap_df <- data.frame("abbreviation" = names(colormap), "color" = unlist(unname(colormap)))
  return(colormap_df)
}


#' @rdname get_aesthetics
#' @export
get_driver_colour_map <- function(season = get_current_season(), round = 1, session = "R") {
  get_driver_color_map(season = season, round = round, session = session)
}


#' @title Driver & Team Look-ups
#' @name driver_team_lookup
#'
#' @description These functions provide the ability to look-up drivers or teams (and match the two) for given
#' races or seasons.
#'
#' `get_driver_abbreviation()` looks up the driver abbreviation (typically 3 letters) as used in the provided season.
#'
#' `get_team_name()` looks up the officially recorded team name based on fuzzy matching to the supplied string. This is
#' fairly inconsistent, for example, "Haas" is recorded as "Haas F1 Team", but not all sponsor names are recorded nor are
#' all names indicating 'F1 Team' --  "RB" is recorded as "RB" and not "Visa Cash App RB F1 Team". If `short = TRUE` then
#' a short form for the team is provided ("Haas" instead of "Haas F1 Team").
#'
#' `get_driver_name()` looks up a driver's full name based on fuzzy matching to the supplied string. The driver has to
#' have participated in the session (season, round, session) for this to match properly. For full-time drivers this is
#' easy, but for rookies who do test FP1 this is a more important note.
#'
#' `get_drivers_by_team()` looks up a team's drivers for the provided race session (season, round, session). If looking
#' for practice rookies, they typically participate in `session = FP1`.
#'
#' `get_team_by_driver()` looks up the team for the specified driver (at the specified race event).
#'
#' `get_session_drivers_and_teams()` returns a data frame of all drivers and their team for a provided session.
#'
#' @param season The season for which the look-up should occur. Should be a number from 2018 to current season.
#' Defaults to current season.
#'
#' @return
#' for `get_session_drivers_and_teams()` a data.frame,
#' for `get_drivers_by_team()` a unnamed character vector with all drivers for the requested team,
#' for all other functions a character result with the requested value.
#'
NULL


#' @rdname driver_team_lookup
#' @param driver_name Driver name (or unique part thereof) to look up.
#'
#' @export
get_driver_abbreviation <- function(driver_name, season = get_current_season) {
  # checks
  if (!is.character(driver_name) | length(driver_name) != 1) {
    cli::cli_abort("{.var driver_name} must be a character vector of length one.")
  }

  # function
  get_session(season = season)

  reticulate::py_run_string("from fastf1.plotting import get_driver_abbreviation")

  py_string <- glue::glue("abbreviation = get_driver_abbreviation('{driver_name}', session)",
    driver_name = driver_name
  )

  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  return(py_env$abbreviation)
}


#' @rdname driver_team_lookup
#'
#' @export
get_driver_name <- function(driver_name, season = get_current_season(), round = 1, session = "R") {
  # checks
  if (!is.character(driver_name) | length(driver_name) != 1) {
    cli::cli_abort("{.var driver_name} must be a character vector of length one.")
  }

  # function
  get_session(season = season, round = round, session = session)

  py_string <- glue::glue("drivername = get_driver_name('{driver_name}', session)",
    driver_name = driver_name
  )

  reticulate::py_run_string("from fastf1.plotting import get_driver_name")
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  return(py_env$drivername)
}


#' @rdname driver_team_lookup
#'
#' @param short whether to provide a shortened version of the team name. Default False.
#' @param team_name The team name (as a string) to use for lookup.
#' @export
get_team_name <- function(team_name, season = get_current_season(), short = FALSE) {
  # checks
  if (!is.character(team_name) | length(team_name) != 1) {
    cli::cli_abort("{.var team_name} must be a character vector of length one.")
  }

  if (!is.logical(short) | length(short) != 1) {
    cli::cli_abort("{.var short} must be a single logical value.")
  }

  # function
  get_session(season = season)

  py_string <- glue::glue("teamname = get_team_name('{team_name}', session, short = {short})",
    team_name = team_name,
    short = ifelse(short, "True", "False")
  )

  reticulate::py_run_string("from fastf1.plotting import get_team_name")
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  return(py_env$teamname)
}


#' @rdname driver_team_lookup
#' @inheritParams load_race_session
#'
#' @export
get_drivers_by_team <- function(team_name, season = get_current_season(), round = 1, session = "R") {
  # checks
  if (!is.character(team_name) | length(team_name) != 1) {
    cli::cli_abort("{.var team_name} must be a character vector of length one.")
  }

  # function
  get_session(season = season, round = round, session = session)

  py_string <- glue::glue("drivers = get_driver_names_by_team('{team_name}', session)",
    team_name = team_name
  )

  reticulate::py_run_string("from fastf1.plotting import get_driver_names_by_team")
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  drivers <- reticulate::py_to_r(reticulate::py_get_item(py_env, "drivers"))

  return(unlist(drivers))
}


#' @rdname driver_team_lookup
#'
#' @export
get_team_by_driver <- function(driver_name, season = get_current_season(), round = 1, short = FALSE) {
  # checks
  if (!is.character(driver_name) | length(driver_name) != 1) {
    cli::cli_abort("{.var driver_name} must be a character vector of length one.")
  }

  if (!is.logical(short) | length(short) != 1) {
    cli::cli_abort("{.var short} must be a single logical value.")
  }

  # function
  get_session(season = season, round = round)

  py_string <- glue::glue("team = get_team_name_by_driver('{driver_name}', session, short = {short})",
    driver_name = driver_name,
    short = ifelse(short, "True", "False")
  )

  reticulate::py_run_string("from fastf1.plotting import get_team_name_by_driver")
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  return(py_env$team)
}


#' @rdname driver_team_lookup
#'
#' @export
get_session_drivers_and_teams <- function(season, round, session = "R") {
  # return name/abbreviation/team data.frame
  # function
  get_session(season = season, round = round, session = session)

  reticulate::py_run_string("from fastf1.plotting import list_driver_abbreviations, get_team_name_by_driver, get_driver_name")

  tryCatch(
    py_env <- reticulate::py_run_string("abbreviations = list_driver_abbreviations(session)"),
    error = function(e) {
      cli::cli_abort(c("Error running FastF1 code:",
        "x" = as.character(e)
      ))
    }
  )

  abbreviations <- reticulate::py_to_r(reticulate::py_get_item(py_env, "abbreviations"))

  driver_team_df <- data.frame(
    name = NA_character_,
    abbreviation = abbreviations,
    team = NA_character_
  )


  for (i in seq_along(driver_team_df$abbreviation)) {
    py_run_string(glue::glue("team = get_team_name_by_driver('{driver}', session)",
      driver = driver_team_df$abbreviation[i]
    ))
    py_run_string(glue::glue("name = get_driver_name('{driver}', session)",
      driver = driver_team_df$abbreviation[i]
    ))
    driver_team_df$team[i] <- py_env$team
    driver_team_df$name[i] <- py_env$name
  }

  return(driver_team_df)
}


#' Get Tire Compounds
#'
#' Get a data.frame of all tire compound names and associated colours for a season.
#'
#' @inheritParams load_race_session
#'
#' @return a data.frame with two columns: `compound` and `color`
#' @export
#'
#' @examples
#' if (interactive()) {
#'   # To get this season's tires
#'   get_tire_compounds()
#'
#'   # Compare to 2018 tires:
#'   get_tire_compounds(2018)
#' }
get_tire_compounds <- function(season = get_current_season()) {
  # function
  get_session(season = season)

  reticulate::py_run_string("from fastf1.plotting import get_compound_mapping")

  py_env <- reticulate::py_run_string("compounds = get_compound_mapping(session)")

  compounds <- py_env$compounds

  compounds_df <- data.frame("compound" = names(compounds), "color" = unlist(unname(compounds)))

  return(compounds_df)
}


#' Get Session
#'
#' @description This preps a `fastf1.get_session()` python call and returns invisibly the python environment
#'
#' @param season number from 2018 to current season. Defaults to current season.
#' @param round number from 1 to 23 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load. Options are `'FP1'`, `'FP2'`, `'FP3'`,
#' `'Q'`, `'S'`, `'SS'`,`'SQ'`, and `'R'`. Default is `'R'`, which refers to Race.
#'
#' @return invisibly, the python environment
#' @keywords internal
get_session <- function(season = get_current_season(), round = 1, session = "R") {
  # checks
  check_ff1_version()
  if (package_version(get_fastf1_version()) < "3.4") {
    cli::cli_abort("{.fn get_driver_style} requires FastF1 version 3.4.0 or later")
  }

  # Function Code
  # only cache to tempdir if cache option is set to memory or off (includes filesystem in vector as a fallback error catch)
  if (getOption("f1dataR.cache", default = "memory") %in% c("memory", "off", "filesystem")) {
    f1datar_cache <- normalizePath(tempdir(), winslash = "/")
  } else {
    f1datar_cache <- normalizePath(getOption("f1dataR.cache"), winslash = "/")
  }

  reticulate::py_run_string("import fastf1")
  reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{cache_dir}')", cache_dir = f1datar_cache))

  py_string <- glue::glue("session = fastf1.get_session({season}, ", season = season)
  if (is.numeric(round)) {
    py_string <- glue::glue("{py_string}{round}, 'R')", py_string = py_string, round = round)
  } else {
    # Character race, so need quotes around it
    py_string <- glue::glue("{py_string}'{round}', 'R')", py_string = py_string, round = round)
  }
  tryCatch(
    py_env <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error loading FastF1 session.",
        "x" = as.character(e)
      ))
    }
  )
  invisible(py_env)
}
