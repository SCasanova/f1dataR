# Load Results

Loads final race results for a given year and round. Use
`.load_results()` for an uncached version

## Usage

``` r
load_results(season = get_current_season(), round = "last")
```

## Arguments

- season:

  number from 1950 to current season (or the word 'current') (defaults
  to current season).

- round:

  number from 1 to 23 (depending on season), and defaults to most
  recent. Also accepts `'last'`.

## Value

A tibble with one row per driver, with columns for driver & constructor
ID, the points won by each driver in the race, their finishing position,
their starting (grid) position, number of completed laps, status code,
gap to leader (or time of race), fastest lap ranking, drivers' fastest
lap time, top speed achieved, and fastest lap time in seconds.
