# Load Session Data

Loads telemetry and general data from the official F1 data stream via
the fastf1 python library. Data is available from 2018 onward.

The data loaded can optionally be assigned to a R variable, and then
interrogated for session data streams. See the [fastf1
documentation](https://docs.fastf1.dev/) for more details on the data
returned by the python API.

Cache directory can be set by setting
`option(f1dataR.cache = [cache dir])`, default is the current working
directory.

## Usage

``` r
load_race_session(
  obj_name = "session",
  season = get_current_season(),
  round = 1,
  session = "R",
  log_level = "WARNING",
  race = lifecycle::deprecated()
)
```

## Arguments

- obj_name:

  name assigned to the loaded session to be referenced later. Leave as
  `'session'` unless otherwise required.

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

- race:

  **\[deprecated\]** `race` is no longer supported, use `round`

## Value

A session object to be used in other functions invisibly.

## See also

[`load_session_laps()`](https://scasanova.github.io/f1dataR/reference/load_session_laps.md)
[`plot_fastest()`](https://scasanova.github.io/f1dataR/reference/plot_fastest.md)

## Examples

``` r
# Load the quali session from 2019 first round
if (interactive()) {
  session <- load_race_session(season = 2019, round = 1, session = "Q")
}
```
