# Get Session

This preps a `fastf1.get_session()` python call and returns invisibly
the python environment

## Usage

``` r
get_session(season = get_current_season(), round = 1, session = "R")
```

## Arguments

- season:

  number from 2018 to current season. Defaults to current season.

- round:

  number from 1 to 23 (depending on season selected) and defaults to
  most recent. Also accepts race name.

- session:

  the code for the session to load. Options are `'FP1'`, `'FP2'`,
  `'FP3'`, `'Q'`, `'S'`, `'SS'`,`'SQ'`, and `'R'`. Default is `'R'`,
  which refers to Race.

## Value

invisibly, the python environment
