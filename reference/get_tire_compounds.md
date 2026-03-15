# Get Tire Compounds

Get a data.frame of all tire compound names and associated colours for a
season.

## Usage

``` r
get_tire_compounds(season = get_current_season())
```

## Arguments

- season:

  number from 2018 to current season. Defaults to current season.

## Value

a data.frame with two columns: `compound` and `color`

## Examples

``` r
if (interactive()) {
  # To get this season's tires
  get_tire_compounds()

  # Compare to 2018 tires:
  get_tire_compounds(2018)
}
```
