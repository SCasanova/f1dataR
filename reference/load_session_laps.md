# Load Lapwise Data

Loads lapwise data for a race session.

Includes each driver's each lap's laptime, pit in/out time, tyre
information, track status, and (optionally) weather information. The
resulting data frame contains a column for the session type. Note that
quali sessions are labelled Q1, Q2 & Q3.

Cache directory can be set by setting
`option(f1dataR.cache = [cache dir])`, default is the current working
directory.

If you have trouble with errors mentioning 'fastf1' or
'get_fastf1_version()' read the 'Setup FastF1 Connection vignette (run
`vignette('setup_fastf1', 'f1dataR')`).

## Usage

``` r
load_session_laps(
  season = get_current_season(),
  round = 1,
  session = "R",
  log_level = "WARNING",
  add_weather = FALSE,
  race = lifecycle::deprecated()
)
```

## Arguments

- season:

  number from 2018 to current season. Defaults to current season.

- round:

  number from 1 to 24 (depending on season selected) and defaults to
  most recent. Also accepts race name.

- session:

  the code for the session to load. Options are `'FP1'`, `'FP2'`,
  `'FP3'`, `'Q'`, `'S'`, `'SS'`,`'SQ'`, and `'R'`. Default is `'R'`,
  which refers to Race.

- log_level:

  Detail of logging from fastf1 to be displayed. Choice of: `'DEBUG'`,
  `'INFO'`, `'WARNING'`, `'ERROR'` and `'CRITICAL.'` See [fastf1
  documentation](https://docs.fastf1.dev/fastf1.html#configure-logging-verbosity).

- add_weather:

  Whether to add weather information to the laps. See [fastf1
  documentation](https://docs.fastf1.dev/core.html#fastf1.core.Laps.get_weather_data)
  for info on weather.

- race:

  **\[deprecated\]** `race` is no longer supported, use `round`

## Value

A tibble. Note time information is in seconds, see [fastf1
documentation](https://docs.fastf1.dev/time_explanation.html) for more
information on timing.
