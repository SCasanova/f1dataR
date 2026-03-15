# Load Standings

Loads standings at the end of a given season and round for drivers' or
constructors' championships. Use `.load_standings()` for an uncached
version of this function.

## Usage

``` r
load_standings(season = get_current_season(), round = "last", type = "driver")
```

## Arguments

- season:

  number from 2003 to current season (defaults to current season).

- round:

  number from 1 to 23 (depending on season), and defaults to most
  recent. Also accepts `'last'`.

- type:

  select `'driver'` or `'constructor'` championship data. Defaults to
  `'driver'`

## Value

A tibble with columns driver_id (or constructor_id), position, points,
wins (and constructors_id in the case of drivers championship).
