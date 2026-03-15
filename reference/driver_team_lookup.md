# Driver & Team Look-ups

These functions provide the ability to look-up drivers or teams (and
match the two) for given races or seasons.

`get_driver_abbreviation()` looks up the driver abbreviation (typically
3 letters) as used in the provided season.

`get_team_name()` looks up the officially recorded team name based on
fuzzy matching to the supplied string. This is fairly inconsistent, for
example, "Haas" is recorded as "Haas F1 Team", but not all sponsor names
are recorded nor are all names indicating 'F1 Team' – "RB" is recorded
as "RB" and not "Visa Cash App RB F1 Team". If `short = TRUE` then a
short form for the team is provided ("Haas" instead of "Haas F1 Team").

`get_driver_name()` looks up a driver's full name based on fuzzy
matching to the supplied string. The driver has to have participated in
the session (season, round, session) for this to match properly. For
full-time drivers this is easy, but for rookies who do test FP1 this is
a more important note.

`get_drivers_by_team()` looks up a team's drivers for the provided race
session (season, round, session). If looking for practice rookies, they
typically participate in `session = FP1`.

`get_team_by_driver()` looks up the team for the specified driver (at
the specified race event).

`get_session_drivers_and_teams()` returns a data frame of all drivers
and their team for a provided session.

## Usage

``` r
get_driver_abbreviation(
  driver_name,
  season = get_current_season(),
  round = 1,
  session = "R"
)

get_driver_name(
  driver_name,
  season = get_current_season(),
  round = 1,
  session = "R"
)

get_team_name(team_name, season = get_current_season(), short = FALSE)

get_drivers_by_team(
  team_name,
  season = get_current_season(),
  round = 1,
  session = "R"
)

get_team_by_driver(
  driver_name,
  season = get_current_season(),
  round = 1,
  short = FALSE
)

get_session_drivers_and_teams(season, round, session = "R")
```

## Arguments

- driver_name:

  Driver name (or unique part thereof) to look up.

- season:

  The season for which the look-up should occur. Should be a number from
  2018 to current season. Defaults to current season.

- round:

  number from 1 to 24 (depending on season selected) and defaults to
  most recent. Also accepts race name.

- session:

  the code for the session to load. Options are `'FP1'`, `'FP2'`,
  `'FP3'`, `'Q'`, `'S'`, `'SS'`,`'SQ'`, and `'R'`. Default is `'R'`,
  which refers to Race.

- team_name:

  The team name (as a string) to use for lookup.

- short:

  whether to provide a shortened version of the team name. Default
  False.

## Value

for `get_session_drivers_and_teams()` a data.frame, for
`get_drivers_by_team()` a unnamed character vector with all drivers for
the requested team, for all other functions a character result with the
requested value.
