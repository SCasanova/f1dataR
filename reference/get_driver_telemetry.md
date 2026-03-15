# Load Telemetry Data for a Driver

**\[deprecated\]**

`get_driver_telemetry()` was renamed to
[`load_driver_telemetry()`](https://scasanova.github.io/f1dataR/reference/load_driver_telemetry.md)
to create a more consistent API.

## Usage

``` r
get_driver_telemetry(
  season = get_current_season(),
  round = 1,
  session = "R",
  driver,
  laps = "fastest",
  log_level = "WARNING",
  fastest_only = lifecycle::deprecated(),
  race = lifecycle::deprecated()
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

- fastest_only:

  **\[deprecated\]** `fastest_only` is no longer supported, indicated
  preferred laps in `laps`.

- race:

  **\[deprecated\]** `race` is no longer supported, use `round`.

## Value

A tibble with telemetry data for selected driver/session.
