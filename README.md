
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

### Load Driver Data

`load_drivers(season = 2022)` This function loads driver data for a
given season. The default is current season.

**Example:**

``` r
load_drivers()
#> # A tibble: 21 × 7
#>    driverId   givenName familyName nationality dateOfBirth code  permanentNumber
#>    <chr>      <chr>     <chr>      <chr>       <chr>       <chr> <chr>          
#>  1 albon      Alexander Albon      Thai        1996-03-23  ALB   23             
#>  2 alonso     Fernando  Alonso     Spanish     1981-07-29  ALO   14             
#>  3 bottas     Valtteri  Bottas     Finnish     1989-08-28  BOT   77             
#>  4 gasly      Pierre    Gasly      French      1996-02-07  GAS   10             
#>  5 hamilton   Lewis     Hamilton   British     1985-01-07  HAM   44             
#>  6 hulkenberg Nico      Hülkenberg German      1987-08-19  HUL   27             
#>  7 latifi     Nicholas  Latifi     Canadian    1995-06-29  LAT   6              
#>  8 leclerc    Charles   Leclerc    Monegasque  1997-10-16  LEC   16             
#>  9 kevin_mag… Kevin     Magnussen  Danish      1992-10-05  MAG   20             
#> 10 norris     Lando     Norris     British     1999-11-13  NOR   4              
#> # … with 11 more rows
```

or

``` r
load_drivers(2013)
#> # A tibble: 23 × 7
#>    driverId   givenName familyName nationality dateOfBirth code  permanentNumber
#>    <chr>      <chr>     <chr>      <chr>       <chr>       <chr> <chr>          
#>  1 alonso     Fernando  Alonso     Spanish     1981-07-29  ALO   14             
#>  2 jules_bia… Jules     Bianchi    French      1989-08-03  BIA   17             
#>  3 bottas     Valtteri  Bottas     Finnish     1989-08-28  BOT   77             
#>  4 button     Jenson    Button     British     1980-01-19  BUT   22             
#>  5 chilton    Max       Chilton    British     1991-04-21  CHI   4              
#>  6 resta      Paul      di Resta   British     1986-04-16  DIR   <NA>           
#>  7 grosjean   Romain    Grosjean   French      1986-04-17  GRO   8              
#>  8 gutierrez  Esteban   Gutiérrez  Mexican     1991-08-05  GUT   21             
#>  9 hamilton   Lewis     Hamilton   British     1985-01-07  HAM   44             
#> 10 hulkenberg Nico      Hülkenberg German      1987-08-19  HUL   27             
#> # … with 13 more rows
```

### Load Schedule

`load_schedule(season = 2022)` This function loads schedule and circuit
data for a given season.

**Example:**

``` r
load_schedule()
#> # A tibble: 22 × 11
#>    season round race_name   circuit_id circuit_name lat   long  locality country
#>    <chr>  <chr> <chr>       <chr>      <chr>        <chr> <chr> <chr>    <chr>  
#>  1 2022   1     Bahrain Gr… bahrain    Bahrain Int… 26.0… 50.5… Sakhir   Bahrain
#>  2 2022   2     Saudi Arab… jeddah     Jeddah Corn… 21.6… 39.1… Jeddah   Saudi …
#>  3 2022   3     Australian… albert_pa… Albert Park… -37.… 144.… Melbour… Austra…
#>  4 2022   4     Emilia Rom… imola      Autodromo E… 44.3… 11.7… Imola    Italy  
#>  5 2022   5     Miami Gran… miami      Miami Inter… 25.9… -80.… Miami    USA    
#>  6 2022   6     Spanish Gr… catalunya  Circuit de … 41.57 2.26… Montmeló Spain  
#>  7 2022   7     Monaco Gra… monaco     Circuit de … 43.7… 7.42… Monte-C… Monaco 
#>  8 2022   8     Azerbaijan… baku       Baku City C… 40.3… 49.8… Baku     Azerba…
#>  9 2022   9     Canadian G… villeneuve Circuit Gil… 45.5  -73.… Montreal Canada 
#> 10 2022   10    British Gr… silversto… Silverstone… 52.0… -1.0… Silvers… UK     
#> # … with 12 more rows, and 2 more variables: date <chr>, time <chr>
```

or

``` r
load_schedule(2011)
#> # A tibble: 19 × 11
#>    season round race_name   circuit_id circuit_name lat   long  locality country
#>    <chr>  <chr> <chr>       <chr>      <chr>        <chr> <chr> <chr>    <chr>  
#>  1 2011   1     Australian… albert_pa… Albert Park… -37.… 144.… Melbour… Austra…
#>  2 2011   2     Malaysian … sepang     Sepang Inte… 2.76… 101.… Kuala L… Malays…
#>  3 2011   3     Chinese Gr… shanghai   Shanghai In… 31.3… 121.… Shanghai China  
#>  4 2011   4     Turkish Gr… istanbul   Istanbul Pa… 40.9… 29.4… Istanbul Turkey 
#>  5 2011   5     Spanish Gr… catalunya  Circuit de … 41.57 2.26… Montmeló Spain  
#>  6 2011   6     Monaco Gra… monaco     Circuit de … 43.7… 7.42… Monte-C… Monaco 
#>  7 2011   7     Canadian G… villeneuve Circuit Gil… 45.5  -73.… Montreal Canada 
#>  8 2011   8     European G… valencia   Valencia St… 39.4… -0.3… Valencia Spain  
#>  9 2011   9     British Gr… silversto… Silverstone… 52.0… -1.0… Silvers… UK     
#> 10 2011   10    German Gra… nurburgri… Nürburgring  50.3… 6.94… Nürburg  Germany
#> # … with 9 more rows, and 2 more variables: date <chr>, time <chr>
```

### Load Pit Stop Data

`load_pitstops(season = 'current', race = 'last')` This function loads
pitstop lap and duration data for a given race. It defaults to current
season and latest race.

**Example:**

``` r
load_pitstops()
#> # A tibble: 32 × 5
#>    driverId        lap   stop  time     duration
#>    <chr>           <chr> <chr> <chr>    <chr>   
#>  1 vettel          5     1     14:10:02 23.406  
#>  2 gasly           5     1     14:10:04 23.557  
#>  3 kevin_magnussen 7     1     14:12:33 38.262  
#>  4 max_verstappen  9     1     14:15:15 24.217  
#>  5 hamilton        9     1     14:15:24 23.845  
#>  6 tsunoda         9     1     14:15:50 23.248  
#>  7 latifi          9     1     14:15:59 24.020  
#>  8 albon           18    1     14:28:07 23.804  
#>  9 russell         19    1     14:29:03 23.951  
#> 10 ocon            19    1     14:29:16 25.684  
#> # … with 22 more rows
```

or

``` r
load_pitstops(2021, 20)
#> # A tibble: 30 × 5
#>    driverId        lap   stop  time     duration
#>    <chr>           <chr> <chr> <chr>    <chr>   
#>  1 tsunoda         9     1     17:17:42 25.659  
#>  2 raikkonen       10    1     17:19:14 26.174  
#>  3 gasly           13    1     17:23:37 25.630  
#>  4 giovinazzi      15    1     17:26:54 25.987  
#>  5 max_verstappen  17    1     17:29:03 25.300  
#>  6 russell         17    1     17:30:00 26.121  
#>  7 hamilton        18    1     17:30:21 25.235  
#>  8 latifi          18    1     17:31:31 25.811  
#>  9 perez           19    1     17:32:28 25.419  
#> 10 mick_schumacher 22    1     17:37:38 25.881  
#> # … with 20 more rows
```

### Load Session Data

`load_session_data(obj_name, season = 2022, race = 1)` This function
loads a session object with all telemetry data for a given race. It
takes a name as an input to assign to said object that can later be used
to get specific data using other functions (such as
`get_driver_telemetry()`).

**Example:**

``` r
load_race_session('bahrain22')
load_race_session('canada18', '2018', 'Canada')
```

### Driver Telemetry

`get_driver_telemetry(session_name, driver, fastest_only = FALSE)` Once
a session is loaded, we can access specific driver telemetry for the
race. The argument session name refers to the name assigned during the
`load_race_session()` step. This function will act on the provided
sesion name. The parameter `fastest_only`, when set to true, will output
the telemetry for the fastest lap exclusiveley.

``` r
get_driver_telemetry('bahrain22', 'PER')
#> # A tibble: 43,384 × 18
#>    Date                SessionTime DriverAhead DistanceToDriverAhead
#>    <dttm>              <dttm>      <chr>                       <dbl>
#>  1 2022-03-20 09:03:34 NA          ""                         0     
#>  2 2022-03-20 09:03:34 NA          ""                         0     
#>  3 2022-03-20 09:03:34 NA          ""                         0     
#>  4 2022-03-20 09:03:35 NA          ""                         0     
#>  5 2022-03-20 09:03:35 NA          ""                         0     
#>  6 2022-03-20 09:03:35 NA          "24"                       0     
#>  7 2022-03-20 09:03:35 NA          "24"                       0.0407
#>  8 2022-03-20 09:03:35 NA          "24"                       0.0815
#>  9 2022-03-20 09:03:35 NA          "77"                       0.122 
#> 10 2022-03-20 09:03:35 NA          "77"                       0.0926
#> # … with 43,374 more rows, and 14 more variables: Time <dttm>, RPM <dbl>,
#> #   Speed <dbl>, nGear <dbl>, Throttle <dbl>, Brake <lgl>, DRS <dbl>,
#> #   Source <chr>, RelativeDistance <dbl>, Status <chr>, …

get_driver_telemetry('canada18', 'HAM', fastest_only = T)
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

### Clear F1 Cache

`clear_f1_cache()` Clears the cache for all functions in the package.

## Loaded Data

The package also includes a static data frame for all current drivers
and their respective constructors. Complete with team colors, logo and
driver number logo.

``` r
f1dataR::driver_constructor_data %>% colnames()
#> [1] "driverId"          "fullName"          "constructor"      
#> [4] "constructorColor"  "constructorColor2" "constructorLogo"  
#> [7] "driverNumber"      "numberImage"       "season"
```
