# Get Aesthetics

Various aesthetics can be retrieved for a driver or team for a specific
session/event.

`get_driver_style()` gets the FastF1 style for a driver for a session -
this includes team colour and line/marker style which should be
reasonably (but not guaranteed) consistent across a season. Based on
FastF1's
[get_driver_style](https://docs.fastf1.dev/plotting.html#fastf1.plotting.get_driver_style).

`get_driver_color()` and its alias `get_driver_colour()` return a
hexidecimal RGB colour code for a driver at a given season & race. Note
that, in contrast to earlier versions, both drivers for a team will be
provided the same color. Use `get_driver_style()` to develop a unique
marker/linestyle for each driver in a team. Data is provided by the
python FastF1 package.

`get_driver_color_mapping()` and its alias `get_driver_colour_mapping()`
return a data.frame of driver short-codes and their hexidecimal colour.
Like `get_driver_color()`, both drivers on a team will get the same
colour returned. Data is provided by the python FastF1 package. Requires
provision of a specific race event (season/round/session).

`get_team_color()` and its alias `get_team_colour()` return a
hexidecimal RGB colour code for a a team at a given season & race. Data
is provided by the python FastF1 package.

## Usage

``` r
get_driver_style(driver, season = get_current_season(), round = 1)

get_driver_color(driver, season = get_current_season(), round = 1)

get_driver_colour(driver, season = get_current_season(), round = 1)

get_team_color(team, season = get_current_season(), round = 1)

get_team_colour(team, season = get_current_season(), round = 1)

get_driver_color_map(season = get_current_season(), round = 1, session = "R")

get_driver_colour_map(season = get_current_season(), round = 1, session = "R")
```

## Arguments

- driver:

  Driver abbreviation or name (FastF1 performs a fuzzy-match to
  ambiguous strings).

- season:

  A season corresponding to the race being referenced for collecting
  colour/style. Should be a number from 2018 to current season. Defaults
  to current season.

- round:

  A round corresponding to the race being referenced for collecting
  colour/style. Should be a string name or a number from 1 to the number
  of rounds in the season and defaults to 1.

- team:

  Team abbreviation or name (FastF1 performs a fuzzy-match to ambiguous
  strings).

- session:

  the code for the session to load. Options are `'FP1'`, `'FP2'`,
  `'FP3'`, `'Q'`, `'S'`, `'SS'`,`'SQ'`, and `'R'`. Default is `'R'`,
  which refers to Race.

## Value

for `get_driver_style()` a named list of graphic parameters for the
provided driver, plus the driver identifier provided and the official
abbreviation matched to that driver (names are `linestyle`, `marker`,
`color`, `driver`, `abbreviation`).

for `get_driver_color()` and `get_team_color()`, a hexidecimal RGB color
value.

## Examples

``` r
if (interactive()) {
  # To get a specific season/race, specify them.
  get_driver_style(driver = "ALO", season = 2024, round = 3)

  # For drivers who haven't moved around recently, get their current season's style:
  get_driver_style(driver = "LEC")

  # Get all driver abbreviations and colors quickly:
  get_driver_color_mapping(season = 2023, round = "Montreal", session = "R")

  get_team_color(team = "Alpine", season = 2023, round = 1)
}
```
