
# f1dataR <img src='man/figures/logo.png' align="right" width="25%" min-width="120px"/>

An R package to access Formula 1 Data from the Ergast API and the
official F1 data stream via the fastf1 python library.

<!-- badges: start -->

[![R-CMD-check](https://github.com/SCasanova/f1dataR/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/SCasanova/f1dataR/actions/workflows/check-standard.yaml)
[![test-coverage](https://github.com/SCasanova/f1dataR/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/SCasanova/f1dataR/actions/workflows/test-coverage.yaml)
[![Codecov test
coverage](https://img.shields.io/codecov/c/github/SCasanova/f1dataR?label=codecov&logo=codecov)](https://app.codecov.io/gh/SCasanova/f1dataR?branch=main)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

<!-- badges: end -->

## Installation

``` r
if (!require("remotes")) install.packages("remotes")
remotes::install_github("SCasanova/f1dataR")
```

## Data Sources

Data is pulled from:

- [Ergast API](http://ergast.com/mrd/)
- [F1 Data Stream](https://www.formula1.com/en/f1-live.html) via the
  [Fast F1 python
  library](https://theoehrly.github.io/Fast-F1/index.html)

## Functions

### Load Lap Times

`load_laps(season = 'current', race = 'last')` This function loads
lap-by-lap time data for all drivers in a given season and round. Round
refers to race number. The defaults are current season and last race.
Lap data is limited to 1996-present.

**Example:**

``` r
library(f1dataR)
#> Loading required package: reticulate
load_laps()
#> # A tibble: 1,315 × 6
#>    driver_id      position time       lap time_sec season
#>    <chr>          <chr>    <chr>    <int>    <dbl>  <dbl>
#>  1 max_verstappen 1        1:23.080     1     83.1   2023
#>  2 hamilton       2        1:23.978     1     84.0   2023
#>  3 alonso         3        1:24.892     1     84.9   2023
#>  4 russell        4        1:25.376     1     85.4   2023
#>  5 ocon           5        1:26.367     1     86.4   2023
#>  6 hulkenberg     6        1:27.105     1     87.1   2023
#>  7 piastri        7        1:27.463     1     87.5   2023
#>  8 norris         8        1:28.099     1     88.1   2023
#>  9 leclerc        9        1:28.596     1     88.6   2023
#> 10 albon          10       1:29.175     1     89.2   2023
#> # ℹ 1,305 more rows
```

or

``` r
load_laps(2021, 15)
#> # A tibble: 1,025 × 6
#>    driver_id position time       lap time_sec season
#>    <chr>     <chr>    <chr>    <int>    <dbl>  <dbl>
#>  1 sainz     1        1:42.997     1     103.   2021
#>  2 norris    2        1:44.272     1     104.   2021
#>  3 russell   3        1:46.318     1     106.   2021
#>  4 stroll    4        1:47.279     1     107.   2021
#>  5 ricciardo 5        1:48.221     1     108.   2021
#>  6 alonso    6        1:49.347     1     109.   2021
#>  7 hamilton  7        1:49.826     1     110.   2021
#>  8 perez     8        1:50.617     1     111.   2021
#>  9 ocon      9        1:51.098     1     111.   2021
#> 10 raikkonen 10       1:51.778     1     112.   2021
#> # ℹ 1,015 more rows
```

### Driver Telemetry

`load_driver_telemetry(season = 'current', race = 'last', session = 'R', driver, fastest_only = FALSE)`

When the parameters for season (four digit year), race (number or GP
name), session (FP1. FP2, FP3, Q, S, SS, or R), and driver code (three
letter code) are entered, the function will load all data for a session
and the pull the info for the selected driver. The first time a session
is called, loading times will be relatively long but in subsequent calls
this will improve to only a couple of seconds

``` r
load_driver_telemetry(2022, round = 4, driver = 'PER')
#> # A tibble: 42,415 × 19
#>    date                session_time driver_ahead distance_to_driver_ahead
#>    <dttm>              <dttm>       <chr>                           <dbl>
#>  1 2022-04-24 09:03:03 NA           ""                             0.0889
#>  2 2022-04-24 09:03:03 NA           ""                             0.0889
#>  3 2022-04-24 09:03:03 NA           ""                             0.0889
#>  4 2022-04-24 09:03:03 NA           "6"                            0.0889
#>  5 2022-04-24 09:03:03 NA           "6"                            0.0593
#>  6 2022-04-24 09:03:03 NA           "6"                            0.0296
#>  7 2022-04-24 09:03:03 NA           "77"                           0     
#>  8 2022-04-24 09:03:04 NA           "77"                           0.0222
#>  9 2022-04-24 09:03:04 NA           "6"                            0.0444
#> 10 2022-04-24 09:03:04 NA           "6"                            0.0444
#> # ℹ 42,405 more rows
#> # ℹ 15 more variables: time <dttm>, rpm <dbl>, speed <dbl>, n_gear <dbl>,
#> #   throttle <dbl>, brake <lgl>, drs <dbl>, source <chr>,
#> #   relative_distance <dbl>, status <chr>, …

load_driver_telemetry(2018, round = 7,'Q', 'HAM', fastest_only = T)
#> # A tibble: 534 × 19
#>    date                session_time driver_ahead distance_to_driver_ahead
#>    <dttm>              <dttm>       <chr>                           <dbl>
#>  1 2018-06-09 14:59:18 NA           ""                               383.
#>  2 2018-06-09 14:59:18 NA           ""                               383.
#>  3 2018-06-09 14:59:18 NA           ""                               383.
#>  4 2018-06-09 14:59:19 NA           "7"                              383.
#>  5 2018-06-09 14:59:19 NA           "7"                              379.
#>  6 2018-06-09 14:59:19 NA           "7"                              375.
#>  7 2018-06-09 14:59:19 NA           "7"                              370.
#>  8 2018-06-09 14:59:19 NA           "7"                              366.
#>  9 2018-06-09 14:59:19 NA           "7"                              362.
#> 10 2018-06-09 14:59:19 NA           "7"                              358.
#> # ℹ 524 more rows
#> # ℹ 15 more variables: time <dttm>, rpm <dbl>, speed <dbl>, n_gear <dbl>,
#> #   throttle <dbl>, brake <lgl>, drs <dbl>, source <chr>,
#> #   relative_distance <dbl>, status <chr>, …
```

### Other functions

- `load_pitstops(season = 'current', round  ='last')`
- `load_drivers(season = 2022)`
- `load_schedule(season = 2022)`
- `load_standings(season = 'current', round = 'last', type = c('driver', 'constructor'))`
- `load_results(season = 'current', round = 'last')`
- `load_quali(season = 'current', round = 'last')`
- `plot_fastest(season = 'current', round = 'last', driver, color = 'gear')`

### Clear F1 Cache

`clear_f1_cache()` Clears the cache for all functions in the package.

## Loaded Data

The package also includes a static data frame for all current drivers
and their respective constructors. Complete with team colors, logo and
driver number logo.

``` r
driver_constructor_data %>% colnames()
#>  [1] "driver_id"          "full_name"          "driver_code"       
#>  [4] "constructor_id"     "constructor_name"   "constructor_color" 
#>  [7] "constructor_color2" "constructor_logo"   "driver_number"     
#> [10] "number_image"       "season"
```
