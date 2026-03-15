# Load Schedule

Loads schedule information for a given F1 season. Use `.load_schedule()`
for an uncached version.

## Usage

``` r
load_schedule(season = get_current_season())
```

## Arguments

- season:

  number from 1950 to current season (defaults to current season).
  `'current'` also accepted.

## Value

A tibble with one row per round in season. Indicates in sprint_date if a
specific round has a sprint race
