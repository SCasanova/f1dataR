# Load Driver Info

Loads driver info for all participants in a given season. Use
`.load_drivers()` for an uncached version of this function.

## Usage

``` r
load_drivers(season = get_current_season())
```

## Arguments

- season:

  number from 1950 to current season (defaults to current season).

## Value

A tibble with columns driver_id (unique and recurring), first name, last
name, nationality, date of birth (yyyy-mm-dd format), driver code, and
permanent number (for post-2014 drivers).
