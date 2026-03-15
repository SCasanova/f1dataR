# Load Qualifying Results

Loads qualifying session results for a given season and round. Use
`.load_quali()` for an uncached version.

## Usage

``` r
load_quali(season = get_current_season(), round = "last")
```

## Arguments

- season:

  number from 2003 to current season (defaults to current season).

- round:

  number from 1 to 23 (depending on season), and defaults to most
  recent. Also accepts `'last'`.

## Value

A tibble with one row per driver
