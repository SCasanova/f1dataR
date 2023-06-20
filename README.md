
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
#> # … with 1,305 more rows
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
#> # … with 1,015 more rows
```

### Driver Telemetry

`load_driver_telemetry(season = 'current', race = 'last', session = 'R', driver, fastest_only = FALSE)`

When the parameters for season (four digit year), round (number or GP
name), session (FP1. FP2, FP3, Q, S, SS, or R), and driver code (three
letter code) are entered, the function will load all data for a session
and the pull the info for the selected driver. The first time a session
is called, loading times will be relatively long but in subsequent calls
this will improve to only a couple of seconds

``` r
load_driver_telemetry(2022, round = 4, driver = 'PER')
#> # A tibble: 42,415 × 19
#>    date                session_time  time   rpm speed n_gear throt…¹ brake   drs
#>    <dttm>                     <dbl> <dbl> <dbl> <dbl>  <dbl>   <dbl> <lgl> <dbl>
#>  1 2022-04-24 15:03:03        3723. 0      9883     0      2      16 FALSE     1
#>  2 2022-04-24 15:03:03        3723. 0.16   9889     0      2      16 FALSE     1
#>  3 2022-04-24 15:03:03        3724. 0.291  9245     0      2      16 FALSE     1
#>  4 2022-04-24 15:03:03        3724. 0.48   8602     0      2      16 FALSE     1
#>  5 2022-04-24 15:03:03        3724. 0.531  8228     2      2      16 FALSE     1
#>  6 2022-04-24 15:03:03        3724. 0.571  7855     4      2      16 FALSE     1
#>  7 2022-04-24 15:03:03        3724. 0.64   7482     7      2      16 FALSE     1
#>  8 2022-04-24 15:03:04        3724. 0.79   6502    10      2      16 FALSE     1
#>  9 2022-04-24 15:03:04        3724. 0.92   5522    13      2      16 FALSE     1
#> 10 2022-04-24 15:03:04        3724. 1.01   5072    15      2      16 FALSE     1
#> # … with 42,405 more rows, 10 more variables: source <chr>,
#> #   relative_distance <dbl>, status <chr>, x <dbl>, y <dbl>, z <dbl>,
#> #   distance <dbl>, driver_ahead <chr>, distance_to_driver_ahead <dbl>,
#> #   driver_code <chr>, and abbreviated variable name ¹​throttle

load_driver_telemetry(2018, round = 7,'Q', 'HAM', fastest_only = T)
#> # A tibble: 534 × 19
#>    date                session_time  time   rpm speed n_gear throt…¹ brake   drs
#>    <dttm>                     <dbl> <dbl> <dbl> <dbl>  <dbl>   <dbl> <lgl> <dbl>
#>  1 2018-06-09 20:59:18        3788. 0     10674   297      8     100 FALSE    12
#>  2 2018-06-09 20:59:18        3788. 0.016 10704   298      8     100 FALSE    12
#>  3 2018-06-09 20:59:18        3788. 0.043 10762   299      8     100 FALSE    12
#>  4 2018-06-09 20:59:19        3788. 0.256 10820   301      8     100 FALSE    12
#>  5 2018-06-09 20:59:19        3788. 0.343 10847   302      8     100 FALSE    12
#>  6 2018-06-09 20:59:19        3788. 0.496 10875   303      8     100 FALSE    12
#>  7 2018-06-09 20:59:19        3789. 0.643 10921   303      8     100 FALSE    12
#>  8 2018-06-09 20:59:19        3789. 0.736 10967   304      8     100 FALSE    12
#>  9 2018-06-09 20:59:19        3789. 0.943 10990   305      8     100 FALSE    12
#> 10 2018-06-09 20:59:19        3789. 0.976 11014   306      8     100 FALSE    12
#> # … with 524 more rows, 10 more variables: source <chr>,
#> #   relative_distance <dbl>, status <chr>, x <dbl>, y <dbl>, z <dbl>,
#> #   distance <dbl>, driver_ahead <chr>, distance_to_driver_ahead <dbl>,
#> #   driver_code <chr>, and abbreviated variable name ¹​throttle
```

### Lap-by-Lap information

This function will give us detailed information of lap and sector times,
tyres, weather (optional), and more for every lap of the GP and driver.

``` r
load_session_laps(season = 2023, round = 4, add_weather = T)
#> # A tibble: 962 × 39
#>     time driver driver_n…¹ lap_t…² lap_n…³ stint pit_o…⁴ pit_i…⁵ secto…⁶ secto…⁷
#>    <dbl> <chr>  <chr>        <dbl>   <dbl> <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#>  1 3892. VER    1             110.       1     1    697.    NaN    NaN      43.2
#>  2 4000. VER    1             108.       2     1    NaN     NaN     38.4    43.6
#>  3 4108. VER    1             108.       3     1    NaN     NaN     38.5    43.7
#>  4 4215. VER    1             107.       4     1    NaN     NaN     37.9    43.4
#>  5 4322. VER    1             107.       5     1    NaN     NaN     38.3    43.4
#>  6 4430. VER    1             107.       6     1    NaN     NaN     38.3    43.2
#>  7 4537. VER    1             107.       7     1    NaN     NaN     38.3    43.0
#>  8 4643. VER    1             107.       8     1    NaN     NaN     38.0    43.0
#>  9 4750. VER    1             107.       9     1    NaN     NaN     38.0    43.1
#> 10 4861. VER    1             111.      10     1    NaN    4860.    37.9    43.4
#> # … with 952 more rows, 29 more variables: sector3time <dbl>,
#> #   sector1session_time <dbl>, sector2session_time <dbl>,
#> #   sector3session_time <dbl>, speed_i1 <dbl>, speed_i2 <dbl>, speed_fl <dbl>,
#> #   speed_st <dbl>, is_personal_best <list>, compound <chr>, …, and abbreviated
#> #   variable names ¹​driver_number, ²​lap_time, ³​lap_number, ⁴​pit_out_time,
#> #   ⁵​pit_in_time, ⁶​sector1time, ⁷​sector2time
```

### Cache information

The cache directory for sessions can be set manually with the options
function

``` r
options(f1dataR.cache = 'path/to/directory')
```

### Other functions

- `load_pitstops(season = 'current', round  ='last')`
- `load_drivers(season = 2022)`
- `load_circuits(season = 2022)`
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
constructor_data %>% colnames()
#> [1] "constructor_id"     "constructor_color"  "constructor_color2"
#> [4] "constructor_logo"
```
