# Load Circuit Info

Loads circuit info for all circuits in a given season. Use
`.load_circuits()` for an uncached version of this function

## Usage

``` r
load_circuits(season = get_current_season())
```

## Arguments

- season:

  number from 1950 to current season (defaults to current season).

## Value

A tibble with one row per circuit
