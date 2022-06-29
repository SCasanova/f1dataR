
# f1dataR <img src='man/figures/logo.png' align="right" width="25%" min-width="120px"/>

A set of functions to easily access Formula 1 data from the Ergast API
and the official F1 data stream via the fastf1 python library.

## Installation

``` r
if (!require("remotes")) install.packages("remotes")
remotes::install_github("SCasanova/f1dataR")
```

## Data Sources

Data is pulled from:

  - [Ergast API](http://ergast.com/mrd/)
  - [F1 Data Stream](https://www.formula1.com/en/f1-live.html/) via the
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
load_laps()
#> # A tibble: 1,262 × 6
#>    driverId        position time       lap time_sec season
#>    <chr>           <chr>    <chr>    <int>    <dbl>  <dbl>
#>  1 max_verstappen  1        1:23.396     1     83.4   2022
#>  2 alonso          2        1:24.435     1     84.4   2022
#>  3 sainz           3        1:25.160     1     85.2   2022
#>  4 hamilton        4        1:26.209     1     86.2   2022
#>  5 kevin_magnussen 5        1:27.088     1     87.1   2022
#>  6 ocon            6        1:27.881     1     87.9   2022
#>  7 russell         7        1:28.761     1     88.8   2022
#>  8 mick_schumacher 8        1:29.342     1     89.3   2022
#>  9 ricciardo       9        1:29.928     1     89.9   2022
#> 10 zhou            10       1:30.286     1     90.3   2022
#> # … with 1,252 more rows
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

`get_driver_telemetry(season = 'current', race = 'last', driver,
fastest_only = FALSE)` When the parameters for season (four digit year),
race (number or GP name), and driver code (three letter code) are
entered, the function will load all data for a session and the pull the
info for the selected driver. The first time a session is called,
loading times will be relatively long but in subsequent calls this will
improve to only a couple of seconds

``` r
get_driver_telemetry(2022, 4, 'PER')
#> The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster
#> # A tibble: 42,415 × 18
#>    Date                SessionTime DriverAhead DistanceToDriverAhead
#>    <dttm>              <dttm>      <chr>                       <dbl>
#>  1 2022-04-24 08:03:03 NA          ""                         0.0889
#>  2 2022-04-24 08:03:03 NA          ""                         0.0889
#>  3 2022-04-24 08:03:03 NA          ""                         0.0889
#>  4 2022-04-24 08:03:03 NA          "6"                        0.0889
#>  5 2022-04-24 08:03:03 NA          "6"                        0.0593
#>  6 2022-04-24 08:03:03 NA          "6"                        0.0296
#>  7 2022-04-24 08:03:03 NA          "77"                       0     
#>  8 2022-04-24 08:03:04 NA          "77"                       0.0222
#>  9 2022-04-24 08:03:04 NA          "6"                        0.0444
#> 10 2022-04-24 08:03:04 NA          "6"                        0.0444
#> # … with 42,405 more rows, and 14 more variables: Time <dttm>, RPM <dbl>,
#> #   Speed <dbl>, nGear <dbl>, Throttle <dbl>, Brake <lgl>, DRS <dbl>,
#> #   Source <chr>, RelativeDistance <dbl>, Status <chr>, …

get_driver_telemetry(2018, 7, 'HAM', fastest_only = T)
#> The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster
#> # A tibble: 550 × 18
#>    Date                SessionTime DriverAhead DistanceToDriverAhead
#>    <dttm>              <dttm>      <chr>                       <dbl>
#>  1 2018-06-10 14:38:05 NA          ""                           66.2
#>  2 2018-06-10 14:38:05 NA          ""                           66.2
#>  3 2018-06-10 14:38:06 NA          ""                           66.2
#>  4 2018-06-10 14:38:06 NA          "3"                          66.2
#>  5 2018-06-10 14:38:06 NA          "3"                          65.6
#>  6 2018-06-10 14:38:06 NA          "3"                          65.1
#>  7 2018-06-10 14:38:06 NA          "3"                          63.8
#>  8 2018-06-10 14:38:06 NA          "3"                          62.6
#>  9 2018-06-10 14:38:06 NA          "3"                          61.3
#> 10 2018-06-10 14:38:07 NA          "3"                          56.4
#> # … with 540 more rows, and 14 more variables: Time <dttm>, RPM <dbl>,
#> #   Speed <dbl>, nGear <dbl>, Throttle <dbl>, Brake <lgl>, DRS <dbl>,
#> #   Source <chr>, RelativeDistance <dbl>, Status <chr>, …
```

### Load Race or Qualifying Results

`load_results(season = 'current', round = 'last')` `load_quali(season =
'current', round = 'last')`

### Other funcitons

  - `load_pitstops(season = 'current', race ='last')`
  - `load_drivers(season = 2022)`
  - `load_schedule(season = 2022)`
  - `load_standings(season = 'current', round = 'last', type =
    c('driver', 'constructor'))`

### Clear F1 Cache

`clear_f1_cache()` Clears the cache for all functions in the package.

## Loaded Data

The package also includes a static data frame for all current drivers
and their respective constructors. Complete with team colors, logo and
driver number logo.

``` r
driver_constructor_data %>% colnames()
#>  [1] "driverId"          "fullName"          "constructorId"    
#>  [4] "constructorName"   "constructorColor"  "constructorColor2"
#>  [7] "constructorLogo"   "driverNumber"      "numberImage"      
#> [10] "season"
```
