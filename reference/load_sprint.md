# Load Sprint Results

Loads final race results for a given year and round. Note not all rounds
have sprint results. Use `.load_sprint()` for an uncached version of
this function.

## Usage

``` r
load_sprint(season = get_current_season(), round = "last")
```

## Arguments

- season:

  number from 2021 to current season (defaults to current season).

- round:

  number from 1 to 23 (depending on season), and defaults to most
  recent. Also accepts `'last'`.

## Value

A dataframetibble with columns driver_id, constructor_id, points
awarded, finishing position, grid position, laps completed, race status
(finished or otherwise), gap to first place, fastest lap, fastest lap
time, fastest lap in seconds, or NULL if no sprint exists for this
season/round combo
