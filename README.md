---
output: github_document
html_document:
    includes:
       in_header: GAfile.html
---





# f1dataR <img src='man/figures/logo.png' align="right" width="25%" min-width="120px"/>

An R package to access Formula 1 Data from the Ergast API and the official F1 data stream via the fastf1 python library.

<!-- badges: start -->

[![R-CMD-check](https://github.com/SCasanova/f1dataR/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/SCasanova/f1dataR/actions/workflows/check-standard.yaml)
[![test-coverage](https://github.com/SCasanova/f1dataR/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/SCasanova/f1dataR/actions/workflows/test-coverage.yaml)
[![Codecov test coverage](https://img.shields.io/codecov/c/github/SCasanova/f1dataR?label=codecov&logo=codecov)](https://app.codecov.io/gh/SCasanova/f1dataR?branch=main)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN status](https://www.r-pkg.org/badges/version/f1dataR)](https://CRAN.R-project.org/package=f1dataR)
<!-- badges: end -->

## Installation


```r
if (!require("remotes")) install.packages("remotes")
remotes::install_github("SCasanova/f1dataR")
```

## Data Sources

Data is pulled from:

* [Ergast API](http://ergast.com/mrd/)
* [F1 Data Stream](https://www.formula1.com/en/f1-live.html) via the [Fast F1 python library](https://theoehrly.github.io/Fast-F1/index.html)

## Functions

### Load Lap Times
`load_laps(season = 'current', race = 'last')`
This function loads lap-by-lap time data for all drivers in a given season
and round. Round refers to race number. The defaults are current season and last race. Lap data is limited to 1996-present.

**Example:**

```r
library(f1dataR)
load_laps()
#> # A tibble: 970 × 6
#>    driver_id      position time       lap time_sec season
#>    <chr>          <chr>    <chr>    <int>    <dbl>  <dbl>
#>  1 norris         1        1:36.551     1     96.6   2023
#>  2 max_verstappen 2        1:37.167     1     97.2   2023
#>  3 piastri        3        1:37.773     1     97.8   2023
#>  4 leclerc        4        1:38.300     1     98.3   2023
#>  5 russell        5        1:38.651     1     98.7   2023
#>  6 sainz          6        1:39.284     1     99.3   2023
#>  7 alonso         7        1:40.026     1    100.    2023
#>  8 hamilton       8        1:40.664     1    101.    2023
#>  9 gasly          9        1:41.014     1    101.    2023
#> 10 albon          10       1:41.364     1    101.    2023
#> # ℹ 960 more rows
```

or


```r
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

When the parameters for season (four digit year), round (number or GP name), session (FP1. FP2, FP3, Q, S, SS, or R), and driver code (three letter code) are entered, the function will load all data for a session and the pull the info for the selected driver. The first time a session is called, loading times will be relatively long but in subsequent calls this will improve to only a couple of seconds


```r
load_driver_telemetry(2022, round = 4, driver = 'PER')
#> # A tibble: 592 × 19
#>    date                session_time  time   rpm speed n_gear throttle brake   drs source  relative_distance status     x
#>    <dttm>                     <dbl> <dbl> <dbl> <dbl>  <dbl>    <dbl> <lgl> <dbl> <chr>               <dbl> <chr>  <dbl>
#>  1 2022-04-24 10:19:27        8308. 0     11221   282      7      100 FALSE     0 interp…        0.00000313 OnTra… -1538
#>  2 2022-04-24 10:19:27        8308. 0.021 11221   283      7      100 FALSE     0 pos            0.000343   OnTra… -1555
#>  3 2022-04-24 10:19:28        8308. 0.278 11221   284      7      100 FALSE     0 car            0.00451    OnTra… -1704
#>  4 2022-04-24 10:19:28        8308. 0.401 11279   285      7      100 FALSE     0 pos            0.00651    OnTra… -1775
#>  5 2022-04-24 10:19:28        8309. 0.678 11337   286      7      100 FALSE     0 car            0.0110     OnTra… -1993
#>  6 2022-04-24 10:19:28        8309. 0.681 11376   287      7      100 FALSE     0 pos            0.0111     OnTra… -1997
#>  7 2022-04-24 10:19:28        8309. 0.86  11416   288      7      100 FALSE     0 pos            0.0140     OnTra… -2189
#>  8 2022-04-24 10:19:29        8309. 1.08  11456   289      7      100 FALSE     0 car            0.0176     OnTra… -2314
#>  9 2022-04-24 10:19:29        8309. 1.18  11461   289      7      100 FALSE     0 pos            0.0193     OnTra… -2381
#> 10 2022-04-24 10:19:29        8309. 1.24  11467   290      7      100 FALSE     0 car            0.0203     OnTra… -2429
#> # ℹ 582 more rows
#> # ℹ 6 more variables: y <dbl>, z <dbl>, distance <dbl>, driver_ahead <chr>, distance_to_driver_ahead <dbl>,
#> #   driver_code <chr>

load_driver_telemetry(2018, round = 7,'Q', 'HAM', fastest_only = T)
#> # A tibble: 534 × 19
#>    date                session_time  time   rpm speed n_gear throttle brake   drs source  relative_distance status     x
#>    <dttm>                     <dbl> <dbl> <dbl> <dbl>  <dbl>    <dbl> <lgl> <dbl> <chr>               <dbl> <chr>  <dbl>
#>  1 2018-06-09 14:59:18        3788. 0     10674   297      8      100 FALSE    12 interp…         0.0000273 OnTra…  3245
#>  2 2018-06-09 14:59:18        3788. 0.016 10704   298      8      100 FALSE    12 car             0.000335  OnTra…  3250
#>  3 2018-06-09 14:59:18        3788. 0.043 10762   299      8      100 FALSE    12 pos             0.000855  OnTra…  3258
#>  4 2018-06-09 14:59:19        3788. 0.256 10820   301      8      100 FALSE    12 car             0.00497   OnTra…  3321
#>  5 2018-06-09 14:59:19        3788. 0.343 10847   302      8      100 FALSE    12 pos             0.00667   OnTra…  3342
#>  6 2018-06-09 14:59:19        3788. 0.496 10875   303      8      100 FALSE    12 car             0.00965   OnTra…  3365
#>  7 2018-06-09 14:59:19        3789. 0.643 10921   303      8      100 FALSE    12 pos             0.0125    OnTra…  3380
#>  8 2018-06-09 14:59:19        3789. 0.736 10967   304      8      100 FALSE    12 car             0.0143    OnTra…  3387
#>  9 2018-06-09 14:59:19        3789. 0.943 10990   305      8      100 FALSE    12 pos             0.0184    OnTra…  3401
#> 10 2018-06-09 14:59:19        3789. 0.976 11014   306      8      100 FALSE    12 car             0.0190    OnTra…  3402
#> # ℹ 524 more rows
#> # ℹ 6 more variables: y <dbl>, z <dbl>, distance <dbl>, driver_ahead <chr>, distance_to_driver_ahead <dbl>,
#> #   driver_code <chr>
```

### Lap-by-Lap information

This function will give us detailed information of lap and sector times, tyres, weather (optional), and more for every lap of the GP and driver.



```r
load_session_laps(season = 2023, round = 4, add_weather = T)
#> # A tibble: 962 × 39
#>     time driver driver_number lap_time lap_number stint pit_out_time pit_in_time sector1time sector2time sector3time
#>    <dbl> <chr>  <chr>            <dbl>      <dbl> <dbl>        <dbl>       <dbl>       <dbl>       <dbl>       <dbl>
#>  1 3892. VER    1                 110.          1     1         697.        NaN        NaN          43.2        25.6
#>  2 4000. VER    1                 108.          2     1         NaN         NaN         38.4        43.6        25.6
#>  3 4108. VER    1                 108.          3     1         NaN         NaN         38.5        43.7        25.5
#>  4 4215. VER    1                 107.          4     1         NaN         NaN         37.9        43.4        25.8
#>  5 4322. VER    1                 107.          5     1         NaN         NaN         38.3        43.4        25.8
#>  6 4430. VER    1                 107.          6     1         NaN         NaN         38.3        43.2        25.7
#>  7 4537. VER    1                 107.          7     1         NaN         NaN         38.3        43.0        25.7
#>  8 4643. VER    1                 107.          8     1         NaN         NaN         38.0        43.0        25.7
#>  9 4750. VER    1                 107.          9     1         NaN         NaN         38.0        43.1        25.8
#> 10 4861. VER    1                 111.         10     1         NaN        4860.        37.9        43.4        29.4
#> # ℹ 952 more rows
#> # ℹ 28 more variables: sector1session_time <dbl>, sector2session_time <dbl>, sector3session_time <dbl>, speed_i1 <dbl>,
#> #   speed_i2 <dbl>, speed_fl <dbl>, speed_st <dbl>, is_personal_best <list>, compound <chr>, tyre_life <dbl>, …
```

### Cache information

The cache directory for sessions can be set manually with the options function


```r
options(f1dataR.cache = 'path/to/directory')
```



### Other functions
* `load_pitstops(season = 'current', round  ='last')`
* `load_drivers(season = 2022)`
* `load_circuits(season = 2022)`
* `load_schedule(season = 2022)`
* `load_standings(season = 'current', round = 'last', type = c('driver', 'constructor'))`
* `load_results(season = 'current', round = 'last')`
* `load_quali(season = 'current', round = 'last')`
* `plot_fastest(season = 'current', round = 'last', driver, color = 'gear')`


### Clear F1 Cache
`clear_f1_cache()`
Clears the cache for all functions in the package.

## Loaded Data

The package also includes a static data frame for all current drivers and their respective constructors. Complete with team colors, logo and driver number logo.


```r
constructor_data %>% colnames()
#> [1] "constructor_id"     "constructor_color"  "constructor_color2" "constructor_logo"
```
