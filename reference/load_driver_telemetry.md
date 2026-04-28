# Load Telemetry Data for a Driver

Receives season, race number, driver code, and an optional fastest lap
only argument to output car telemetry for the selected situation.
Example usage of this code can be seen in the Introduction vignette (run
[`vignette('introduction', 'f1dataR')`](https://scasanova.github.io/f1dataR/articles/introduction.md)
to read). Multiple drivers' telemetry can be appended to one data frame
by the user.

## Usage

``` r
load_driver_telemetry(
  season = get_current_season(),
  round = 1,
  session = "R",
  driver,
  laps = "fastest",
  log_level = "WARNING",
  race = lifecycle::deprecated(),
  fastest_only = lifecycle::deprecated()
)
```

## Arguments

- season:

  number from 2018 to current season (defaults to current season).

- round:

  number from 1 to 23 (depending on season selected). Also accepts race
  name.

- session:

  the code for the session to load Options are `'FP1'`, `'FP2'`,
  `'FP3'`, `'Q'`, `'S'`, `'SS'`, `'SQ'`, and `'R'`. Default is `'R'`,
  which refers to Race.

- driver:

  three letter driver code (see
  [`load_drivers()`](https://scasanova.github.io/f1dataR/reference/load_drivers.md)
  for a list)

- laps:

  which lap's telemetry to return. One of an integer lap number (\<=
  total laps in the race), `fastest`, or `all`. Note that integer lap
  choice requires `fastf1` version 3.0 or greater.

- log_level:

  Detail of logging from fastf1 to be displayed. Choice of: `'DEBUG'`,
  `'INFO'`, `'WARNING'`, `'ERROR'` and `'CRITICAL'`. See [fastf1
  documentation](https://docs.fastf1.dev/fastf1.html#configure-logging-verbosity).

- race:

  **\[deprecated\]** `race` is no longer supported, use `round`.

- fastest_only:

  **\[deprecated\]** `fastest_only` is no longer supported, indicated
  preferred laps in `laps`.

## Value

A tibble with telemetry data for selected driver/session.

## Examples

``` r
if (interactive()) {
  telem <- load_driver_telemetry(
    season = 2023,
    round = "Bahrain",
    session = "Q",
    driver = "HAM",
    laps = "fastest"
  )
}
```
