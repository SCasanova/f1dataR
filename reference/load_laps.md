# Load Lap by Lap Time Data

Loads basic lap-by-lap time data for all drivers in a given season and
round. Lap time data is available from 1996 onward. Use `.load_laps()`
for a uncached version.

## Usage

``` r
load_laps(
  season = get_current_season(),
  round = "last",
  race = lifecycle::deprecated()
)
```

## Arguments

- season:

  number from 1996 to current season (defaults to current season).

- round:

  number from 1 to 23 (depending on season selected) and defaults to
  most recent. Also accepts `'last'`.

- race:

  **\[deprecated\]** `race` is no longer supported, use `round`.

## Value

A tibble with columns driver_id (unique and recurring), position during
lap, time (in clock form), lap number, time (in seconds), and season.
