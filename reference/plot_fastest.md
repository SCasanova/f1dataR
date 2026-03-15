# Plot Fastest Lap

Creates a ggplot graphic that details the fastest lap for a driver in a
race. Complete with a gearshift or speed analysis.

## Usage

``` r
plot_fastest(
  season = get_current_season(),
  round = 1,
  session = "R",
  driver,
  color = "gear",
  race = lifecycle::deprecated()
)
```

## Arguments

- season:

  number from 2018 to current season (defaults to current season).

- round:

  number from 1 to 23 (depending on season selected) and defaults to
  most recent.

- session:

  the code for the session to load Options are `'FP1'`, `'FP2'`,
  `'FP3'`, `'Q'`, `'S'`, `'SS'`, `'SQ'`, and `'R'`. Default is `'R'`,
  which refers to Race.

- driver:

  three letter driver code (see load_drivers() for a list) or name to be
  fuzzy matched to a driver from the session if FastF1 \>= 3.4.0 is
  available.

- color:

  argument that indicates which variable to plot along the circuit.
  Choice of `'gear'` or `'speed'`, default `'gear'`.

- race:

  number from 1 to 23 (depending on season selected) and defaults to
  most recent.

## Value

A ggplot object that indicates grand prix, driver, time and selected
color variable.

## Examples

``` r
# Plot Verstappen's fastest lap (speed) from Bahrain 2023:
if (interactive()) {
  plot_fastest(2023, 1, "R", "VER", "speed")
}
```
