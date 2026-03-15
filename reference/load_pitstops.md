# Load Pitstop Data

Loads pit stop info (number, lap, time elapsed) for a given race in a
season. Pit stop data is available from 2012 onward. Call
`.load_pitstops()` for an uncached version.

## Usage

``` r
load_pitstops(
  season = get_current_season(),
  round = "last",
  race = lifecycle::deprecated()
)
```

## Arguments

- season:

  number from 2011 to current season (defaults to current season).

- round:

  number from 1 to 23 (depending on season selected) and defaults to
  most recent.Also accepts `'last'`.

- race:

  **\[deprecated\]** `race` is no longer supported, please use `round`.

## Value

A tibble with columns driver_id, lap, stop (number), time (of day), and
stop duration
