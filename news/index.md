# Changelog

## f1dataR 2.0.2

- Updated code to match new `reticulate` interface for package and
  environment management
  ([\#300](https://github.com/SCasanova/f1dataR/issues/300)).
  - Documented changes (including requirement for `reticulate`
    `v1.46.0`).
- Updated tests to use `vcr` package to reduce hits on the Jolpica API.
- Removed support for FastF1 v \< 3.0 (now causes errors instead of
  warnings).
- Test suite and automated testing changes to reflect the above changes.
- Refactored out `case_match` which was deprecated from `dplyr`.
- Fixed a data conversion issue in
  [`time_to_sec()`](https://scasanova.github.io/f1dataR/reference/time_to_sec.md)
  ([\#290](https://github.com/SCasanova/f1dataR/issues/290)).
- Updated testing to comply with changes in `ggplot2`
  ([\#292](https://github.com/SCasanova/f1dataR/issues/292)).
- Updated data conversions to avoid bugs after changes in Jolpica
  database. ([\#281](https://github.com/SCasanova/f1dataR/issues/281),
  [\#284](https://github.com/SCasanova/f1dataR/issues/284),
  [\#298](https://github.com/SCasanova/f1dataR/issues/298),
  [\#299](https://github.com/SCasanova/f1dataR/issues/299))

## f1dataR 2.0.1

CRAN release: 2025-03-27

- Forced fail-over from Ergast to Jolpica (still deprecated at ‘warn’
  level).
- Fixed a pre-season bug where Jolpica API was missing a column in
  `load_season()`.
- Fixed a bug resulting from a change in API for 2025 season - Thanks to
  [@appiehappie999](https://github.com/appiehappie999).
  ([\#277](https://github.com/SCasanova/f1dataR/issues/277))

## f1dataR 2.0.0

CRAN release: 2025-03-01

- Deprecated Ergast and moved to Jolpica API for Ergast Functions. While
  this is not a breaking change in the code syntax, the documentation
  changes significantly to reflect this and a new major version is
  appropriate.
  ([\#268](https://github.com/SCasanova/f1dataR/issues/268))
- Bugfix in
  [`plot_fastest()`](https://scasanova.github.io/f1dataR/reference/plot_fastest.md).
- Bugfix in
  [`load_results()`](https://scasanova.github.io/f1dataR/reference/load_results.md)
  with pagination - Thanks to
  [@awanderingspirit](https://github.com/awanderingspirit).
  ([\#272](https://github.com/SCasanova/f1dataR/issues/272))
- Bugfix in README.
  ([\#267](https://github.com/SCasanova/f1dataR/issues/267))

## f1dataR 1.6.0

CRAN release: 2024-08-27

- Updates per FastF1 (python) updates at 3.4.0
  [\#259](https://github.com/SCasanova/f1dataR/issues/259)
  - Soft deprecates FastF1 v \< 3.4.0, hard deprecates FastF1 v \<
    3.1.0.
  - Added functions to get driver graphic style & team colors from
    FastF1. See
    [`get_driver_style()`](https://scasanova.github.io/f1dataR/reference/get_aesthetics.md),
    [`get_driver_color()`](https://scasanova.github.io/f1dataR/reference/get_aesthetics.md),
    [`get_team_color()`](https://scasanova.github.io/f1dataR/reference/get_aesthetics.md)
    and
    [`get_driver_color_map()`](https://scasanova.github.io/f1dataR/reference/get_aesthetics.md)
    (and the aliases with `colour`).
  - Added functions for look-ups of driver & team information for
    seasons/sessions. See
    [`get_driver_abbreviation()`](https://scasanova.github.io/f1dataR/reference/driver_team_lookup.md),
    [`get_driver_name()`](https://scasanova.github.io/f1dataR/reference/driver_team_lookup.md),
    [`get_team_by_driver()`](https://scasanova.github.io/f1dataR/reference/driver_team_lookup.md),
    [`get_team_name()`](https://scasanova.github.io/f1dataR/reference/driver_team_lookup.md),
    [`get_drivers_by_team()`](https://scasanova.github.io/f1dataR/reference/driver_team_lookup.md).
  - Removed `constructor_data` object from package vignettes, readme,
    examples, etc.
  - Expanded vignettes to improve graphics & demonstrate lookups.
- Removed `usethis` from Suggests (only needed when changing data)
- Updated tests to avoid API failure for 2022 season & better
  skip-on-CRAN for internet resources
- Updated minimum R to 3.5.0, reflecting imported package requirements.

## f1dataR 1.5.3

CRAN release: 2024-05-01

- Enabled Sprint Qualifying “SQ” as a session type in line with FastF1
  v3.3.5.

## f1dataR 1.5.2

CRAN release: 2024-04-15

- Modified testing to satisfy CRAN requirements.
- Added vignette looking at telemetry plots through Alonso’s 2024
  Australia penalty.

## f1dataR 1.5.1

CRAN release: 2024-03-12

- Added (very soft) deprecation warning to Ergast functions in advance
  of the Ergast API being defunct in less than 12 months.
- Deprecated support for FastF1 v \< 3.1.0. Older FastF1 versions do not
  support all of the functions in use and may return different values
  from some data retrieval or calculation functions. Forcing use of
  up-to-date FastF1 allows for simpler bugfixes and code updates.
  ([\#198](https://github.com/SCasanova/f1dataR/issues/198))
- Removed Ergast check for
  [`get_current_season()`](https://scasanova.github.io/f1dataR/reference/get_current_season.md)
  ([\#227](https://github.com/SCasanova/f1dataR/issues/227))
- Improved messaging to users regarding updating FastF1
  ([\#226](https://github.com/SCasanova/f1dataR/issues/226))
- Named items in list returned by
  [`load_circuit_details()`](https://scasanova.github.io/f1dataR/reference/load_circuit_details.md)
- Changed the way that
  [`correct_track_ratio()`](https://scasanova.github.io/f1dataR/reference/correct_track_ratio.md)
  works. Visually the results are the same, but now any
  labels/annotations added to the ggplot should be kept in the right
  spot.
- Added Vignette describing some
  [`load_circuit_details()`](https://scasanova.github.io/f1dataR/reference/load_circuit_details.md)
  usage.
- Code improvements (better handle variation in Ergast response, better
  handle Ergast connection failures)
  ([\#228](https://github.com/SCasanova/f1dataR/issues/228))
- Testing improvements to validate our handling of internet failures
  ([\#228](https://github.com/SCasanova/f1dataR/issues/228))
- Upgraded to use `httptest2` for testing no-internet scenarios (no
  affect on package performance)
- Code cleanup (removed old inaccessible code, centralized repeated
  steps to functions, etc.)

## f1dataR 1.5.0

CRAN release: 2024-01-25

- Added `load_circuit_details`
  ([\#210](https://github.com/SCasanova/f1dataR/issues/210))
- Strengthened package testing
  ([\#212](https://github.com/SCasanova/f1dataR/issues/212),
  [\#216](https://github.com/SCasanova/f1dataR/issues/216))
- Bugfixes ([\#216](https://github.com/SCasanova/f1dataR/issues/216))

## f1dataR 1.4.1

CRAN release: 2023-11-13

- Fixed a bug with cache options
  ([\#194](https://github.com/SCasanova/f1dataR/issues/194),
  [\#195](https://github.com/SCasanova/f1dataR/issues/195),
  [\#197](https://github.com/SCasanova/f1dataR/issues/197))
- Fixed a build bug
- Began deprecation of support for FastF1 v \< 3.1.0

## f1dataR 1.4.0

CRAN release: 2023-10-03

- Fully deprecated `round` and `fastest_only` arguments
- Added a function
  [`correct_track_ratio()`](https://scasanova.github.io/f1dataR/reference/correct_track_ratio.md)
  to ensure plotted tracks have proper x & y ratios
  ([\#89](https://github.com/SCasanova/f1dataR/issues/89),
  [\#179](https://github.com/SCasanova/f1dataR/issues/179))
  - Updated
    [`plot_fastest()`](https://scasanova.github.io/f1dataR/reference/plot_fastest.md)
    to use
    [`correct_track_ratio()`](https://scasanova.github.io/f1dataR/reference/correct_track_ratio.md)
- Added a function to help switch between cache choices
  ([\#170](https://github.com/SCasanova/f1dataR/issues/170),
  [\#171](https://github.com/SCasanova/f1dataR/issues/171))
  - Ensured cache option had default (`"memory"`)
    ([\#181](https://github.com/SCasanova/f1dataR/issues/181),
    [\#183](https://github.com/SCasanova/f1dataR/issues/183))
- Simplified Python package `fastf1` installation
  ([\#187](https://github.com/SCasanova/f1dataR/issues/187)).
  - Virtualenv and Conda environment management is up to the user now

## f1dataR 1.3.0

CRAN release: 2023-08-17

- Updated documentation per requirements after CRAN review
- Changed caching behavior per requirements after CRAN review. If you
  previously had set a cache directory
  `options("f1dataR.cache" = [dir])` there will be no change. If you had
  previously not specified a cache directory, the package used to use
  the result of [`getwd()`](https://rdrr.io/r/base/getwd.html), so you
  can force that directory. New users can specify a default file cache
  location by setting `options("f1dataR.cache" = "filesystem")` or
  specify any other (existing) directory by setting the option.

Cache will otherwise use memory as a default until the end of the R
session or for 24h (whichever comes first). Caching can be turned off by
setting the option to “off”

## f1dataR 1.2.1

- Added additional output column to
  [`load_schedule()`](https://scasanova.github.io/f1dataR/reference/load_schedule.md)
  to show Sprint Race date.

## f1dataR 1.2.0

- Added a helper function for setting up `fastf1` connection.
- Improved testing coverage
- Code style and format cleanups

## f1dataR 1.1.0

- Updated load_driver_telemetry to use `laps` parameter, allowing for a
  choice of ‘fastest’, ‘all’, or a numbered lap. Note a numbered lap
  requires `fastf1` version 3.0 or greater
  ([\#78](https://github.com/SCasanova/f1dataR/issues/78))

## f1dataR 1.0.1

- Added examples to documentation
  ([\#95](https://github.com/SCasanova/f1dataR/issues/95))

## f1dataR 1.0.0

- Added a `NEWS.md` file to track changes to the package.
