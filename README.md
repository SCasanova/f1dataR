
# f1dataR <img src='man/figures/logo.png' align="right" width="25%" min-width="120px"/>

An R package to access Formula 1 Data from the Ergast API and the
official F1 data stream via the fastf1 python library.

<!-- badges: start -->

[![R-CMD-check](https://github.com/SCasanova/f1dataR/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/SCasanova/f1dataR/actions/workflows/check-standard.yaml)
[![test-coverage](https://github.com/SCasanova/f1dataR/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/SCasanova/f1dataR/actions/workflows/test-coverage.yaml)
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
#> # A tibble: 1,117 × 6
#>    driverId       position time       lap time_sec season
#>    <chr>          <chr>    <chr>    <int>    <dbl>  <dbl>
#>  1 max_verstappen 1        1:32.198     1     92.2   2022
#>  2 perez          2        1:33.251     1     93.3   2022
#>  3 leclerc        3        1:34.192     1     94.2   2022
#>  4 hamilton       4        1:34.864     1     94.9   2022
#>  5 sainz          5        1:35.436     1     95.4   2022
#>  6 norris         6        1:35.908     1     95.9   2022
#>  7 russell        7        1:36.506     1     96.5   2022
#>  8 ocon           8        1:36.964     1     97.0   2022
#>  9 vettel         9        1:37.455     1     97.5   2022
#> 10 alonso         10       1:38.193     1     98.2   2022
#> # … with 1,107 more rows
```

or

``` r
load_laps(2021, 15)
#> # A tibble: 1,025 × 6
#>    driverId  position time       lap time_sec season
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

`get_driver_telemetry(season = 'current', race = 'last', session = 'R', driver, fastest_only = FALSE)`

When the parameters for season (four digit year), race (number or GP
name), session (FP1. FP2, FP3, Q, S, SS, or R), and driver code (three
letter code) are entered, the function will load all data for a session
and the pull the info for the selected driver. The first time a session
is called, loading times will be relatively long but in subsequent calls
this will improve to only a couple of seconds

``` r
get_driver_telemetry(2022, 4, driver = 'PER')
#> The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster
#> # A tibble: 42,415 × 19
#>    Date                SessionTime DriverAhead DistanceToD…¹ Time  
#>    <dttm>              <dttm>      <chr>               <dbl> <dttm>
#>  1 2022-04-24 09:03:03 NA          ""                 0.0889 NA    
#>  2 2022-04-24 09:03:03 NA          ""                 0.0889 NA    
#>  3 2022-04-24 09:03:03 NA          ""                 0.0889 NA    
#>  4 2022-04-24 09:03:03 NA          "6"                0.0889 NA    
#>  5 2022-04-24 09:03:03 NA          "6"                0.0593 NA    
#>  6 2022-04-24 09:03:03 NA          "6"                0.0296 NA    
#>  7 2022-04-24 09:03:03 NA          "77"               0      NA    
#>  8 2022-04-24 09:03:04 NA          "77"               0.0222 NA    
#>  9 2022-04-24 09:03:04 NA          "6"                0.0444 NA    
#> 10 2022-04-24 09:03:04 NA          "6"                0.0444 NA    
#> # … with 42,405 more rows, 14 more variables: RPM <dbl>, Speed <dbl>,
#> #   nGear <dbl>, Throttle <dbl>, Brake <lgl>, DRS <dbl>, Source <chr>,
#> #   RelativeDistance <dbl>, Status <chr>, X <dbl>, …, and abbreviated variable
#> #   name ¹​DistanceToDriverAhead

get_driver_telemetry(2018, 7,'Q', 'HAM', fastest_only = T)
#> The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster
#> # A tibble: 534 × 19
#>    Date                SessionTime DriverAhead DistanceToD…¹ Time  
#>    <dttm>              <dttm>      <chr>               <dbl> <dttm>
#>  1 2018-06-09 14:59:18 NA          ""                   383. NA    
#>  2 2018-06-09 14:59:18 NA          ""                   383. NA    
#>  3 2018-06-09 14:59:18 NA          ""                   383. NA    
#>  4 2018-06-09 14:59:19 NA          "7"                  383. NA    
#>  5 2018-06-09 14:59:19 NA          "7"                  379. NA    
#>  6 2018-06-09 14:59:19 NA          "7"                  375. NA    
#>  7 2018-06-09 14:59:19 NA          "7"                  370. NA    
#>  8 2018-06-09 14:59:19 NA          "7"                  366. NA    
#>  9 2018-06-09 14:59:19 NA          "7"                  362. NA    
#> 10 2018-06-09 14:59:19 NA          "7"                  358. NA    
#> # … with 524 more rows, 14 more variables: RPM <dbl>, Speed <dbl>, nGear <dbl>,
#> #   Throttle <dbl>, Brake <lgl>, DRS <dbl>, Source <chr>,
#> #   RelativeDistance <dbl>, Status <chr>, X <dbl>, …, and abbreviated variable
#> #   name ¹​DistanceToDriverAhead
```

### Other funcitons

- `load_pitstops(season = 'current', race  ='last')`
- `load_drivers(season = 2022)`
- `load_schedule(season = 2022)`
- `load_standings(season = 'current', round = 'last', type = c('driver', 'constructor'))`
- `load_results(season = 'current', round = 'last')`
- `load_quali(season = 'current', round = 'last')`
- `plot_fastest(season = 'current', race = 'last', driver, color = 'gear')`

### Clear F1 Cache

`clear_f1_cache()` Clears the cache for all functions in the package.

## Loaded Data

The package also includes a static data frame for all current drivers
and their respective constructors. Complete with team colors, logo and
driver number logo.

``` r
driver_constructor_data %>% colnames()
#>  [1] "driverId"          "fullName"          "driverCode"       
#>  [4] "constructorId"     "constructorName"   "constructorColor" 
#>  [7] "constructorColor2" "constructorLogo"   "driverNumber"     
#> [10] "numberImage"       "season"
```
