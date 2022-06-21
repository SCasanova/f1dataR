# A set of functions to easily access Formula 1 data from the Ergast API.

## Installation

```{r eval = FALSE}
if (!require("remotes")) install.packages("remotes")
remotes::install_github("SCasanova/f1dataR")
```


## Functions

### Load Lap Times
`load_laps()`
This function loads lap-by-lap time data for all drivers in a given season
and round. Round refers to race number. The defaults are current season and last race. Lap data is limited to 1996-present.

**Example:**
```{r}
load_laps()

# A tibble: 1,262 × 6
   driverId        position time       lap time_sec season 
   <chr>           <chr>    <chr>    <int>    <dbl> <chr>  
 1 max_verstappen  1        1:23.396     1     83.4 current
 2 alonso          2        1:24.435     1     84.4 current
 3 sainz           3        1:25.160     1     85.2 current
 4 hamilton        4        1:26.209     1     86.2 current
 5 kevin_magnussen 5        1:27.088     1     87.1 current
 6 ocon            6        1:27.881     1     87.9 current
 7 russell         7        1:28.761     1     88.8 current
 8 mick_schumacher 8        1:29.342     1     89.3 current
 9 ricciardo       9        1:29.928     1     89.9 current
10 zhou            10       1:30.286     1     90.3 current
# … with 1,252 more rows
```

or

```{r}
load_laps(2021, 15)

# A tibble: 1,025 × 6
   driverId  position time       lap time_sec season
   <chr>     <chr>    <chr>    <int>    <dbl>  <dbl>
 1 sainz     1        1:42.997     1     103.   2021
 2 norris    2        1:44.272     1     104.   2021
 3 russell   3        1:46.318     1     106.   2021
 4 stroll    4        1:47.279     1     107.   2021
 5 ricciardo 5        1:48.221     1     108.   2021
 6 alonso    6        1:49.347     1     109.   2021
 7 hamilton  7        1:49.826     1     110.   2021
 8 perez     8        1:50.617     1     111.   2021
 9 ocon      9        1:51.098     1     111.   2021
10 raikkonen 10       1:51.778     1     112.   2021
# … with 1,015 more rows
```

### Load Driver Data
`load_drivers()`
This function loads driver data for a given season. The default is current season.

**Example:**
```{r}
load_drivers()

# A tibble: 21 × 7
   driverId givenName familyName nationality dateOfBirth code 
   <chr>    <chr>     <chr>      <chr>       <chr>       <chr>
 1 albon    Alexander Albon      Thai        1996-03-23  ALB  
 2 alonso   Fernando  Alonso     Spanish     1981-07-29  ALO  
 3 bottas   Valtteri  Bottas     Finnish     1989-08-28  BOT  
 4 gasly    Pierre    Gasly      French      1996-02-07  GAS  
 5 hamilton Lewis     Hamilton   British     1985-01-07  HAM  
 6 hulkenb… Nico      Hülkenberg German      1987-08-19  HUL  
 7 latifi   Nicholas  Latifi     Canadian    1995-06-29  LAT  
 8 leclerc  Charles   Leclerc    Monegasque  1997-10-16  LEC  
 9 kevin_m… Kevin     Magnussen  Danish      1992-10-05  MAG  
10 norris   Lando     Norris     British     1999-11-13  NOR  
# … with 11 more rows, and 1 more variable:
#   permanentNumber <chr>
```

or

```{r}
load_drivers(2013))

# A tibble: 23 × 7
   driverId givenName familyName nationality dateOfBirth code 
   <chr>    <chr>     <chr>      <chr>       <chr>       <chr>
 1 alonso   Fernando  Alonso     Spanish     1981-07-29  ALO  
 2 jules_b… Jules     Bianchi    French      1989-08-03  BIA  
 3 bottas   Valtteri  Bottas     Finnish     1989-08-28  BOT  
 4 button   Jenson    Button     British     1980-01-19  BUT  
 5 chilton  Max       Chilton    British     1991-04-21  CHI  
 6 resta    Paul      di Resta   British     1986-04-16  DIR  
 7 grosjean Romain    Grosjean   French      1986-04-17  GRO  
 8 gutierr… Esteban   Gutiérrez  Mexican     1991-08-05  GUT  
 9 hamilton Lewis     Hamilton   British     1985-01-07  HAM  
10 hulkenb… Nico      Hülkenberg German      1987-08-19  HUL  
# … with 13 more rows, and 1 more variable:
#   permanentNumber <chr>
```

### Load Schedule
`load_schedule()`
This function loads schedule and circuit data for a given season.

**Example:**
```{r}
load_schedule()

# A tibble: 22 × 11
   season round race_name  circuit_id circuit_name lat   long 
   <chr>  <chr> <chr>      <chr>      <chr>        <chr> <chr>
 1 2022   1     Bahrain G… bahrain    Bahrain Int… 26.0… 50.5…
 2 2022   2     Saudi Ara… jeddah     Jeddah Corn… 21.6… 39.1…
 3 2022   3     Australia… albert_pa… Albert Park… -37.… 144.…
 4 2022   4     Emilia Ro… imola      Autodromo E… 44.3… 11.7…
 5 2022   5     Miami Gra… miami      Miami Inter… 25.9… -80.…
 6 2022   6     Spanish G… catalunya  Circuit de … 41.57 2.26…
 7 2022   7     Monaco Gr… monaco     Circuit de … 43.7… 7.42…
 8 2022   8     Azerbaija… baku       Baku City C… 40.3… 49.8…
 9 2022   9     Canadian … villeneuve Circuit Gil… 45.5  -73.…
10 2022   10    British G… silversto… Silverstone… 52.0… -1.0…
# … with 12 more rows, and 4 more variables: locality <chr>,
#   country <chr>, date <chr>, time <chr>
```

or

```{r}
load_drivers(2011)

# A tibble: 19 × 11
   season round race_name  circuit_id circuit_name lat   long 
   <chr>  <chr> <chr>      <chr>      <chr>        <chr> <chr>
 1 2011   1     Australia… albert_pa… Albert Park… -37.… 144.…
 2 2011   2     Malaysian… sepang     Sepang Inte… 2.76… 101.…
 3 2011   3     Chinese G… shanghai   Shanghai In… 31.3… 121.…
 4 2011   4     Turkish G… istanbul   Istanbul Pa… 40.9… 29.4…
 5 2011   5     Spanish G… catalunya  Circuit de … 41.57 2.26…
 6 2011   6     Monaco Gr… monaco     Circuit de … 43.7… 7.42…
 7 2011   7     Canadian … villeneuve Circuit Gil… 45.5  -73.…
 8 2011   8     European … valencia   Valencia St… 39.4… -0.3…
 9 2011   9     British G… silversto… Silverstone… 52.0… -1.0…
10 2011   10    German Gr… nurburgri… Nürburgring  50.3… 6.94…
11 2011   11    Hungarian… hungarori… Hungaroring  47.5… 19.2…
12 2011   12    Belgian G… spa        Circuit de … 50.4… 5.97…
13 2011   13    Italian G… monza      Autodromo N… 45.6… 9.28…
14 2011   14    Singapore… marina_bay Marina Bay … 1.29… 103.…
15 2011   15    Japanese … suzuka     Suzuka Circ… 34.8… 136.…
16 2011   16    Korean Gr… yeongam    Korean Inte… 34.7… 126.…
17 2011   17    Indian Gr… buddh      Buddh Inter… 28.3… 77.5…
18 2011   18    Abu Dhabi… yas_marina Yas Marina … 24.4… 54.6…
19 2011   19    Brazilian… interlagos Autódromo J… -23.… -46.…
# … with 4 more variables: locality <chr>, country <chr>,
#   date <chr>, time <chr>
```

### Load Pit Stop Data
`load_pitstops()`
This function loads pitstop lap and duration data for a given race. It defaults to current season and latest race.

**Example:**
```{r}
load_pitstops()

# A tibble: 32 × 5
   driverId        lap   stop  time     duration
   <chr>           <chr> <chr> <chr>    <chr>   
 1 vettel          5     1     14:10:02 23.406  
 2 gasly           5     1     14:10:04 23.557  
 3 kevin_magnussen 7     1     14:12:33 38.262  
 4 max_verstappen  9     1     14:15:15 24.217  
 5 hamilton        9     1     14:15:24 23.845  
 6 tsunoda         9     1     14:15:50 23.248  
 7 latifi          9     1     14:15:59 24.020  
 8 albon           18    1     14:28:07 23.804  
 9 russell         19    1     14:29:03 23.951  
10 ocon            19    1     14:29:16 25.684  
# … with 22 more rows
```

or

```{r}
load_pitstops(2021, 20)

# A tibble: 30 × 5
   driverId        lap   stop  time     duration
   <chr>           <chr> <chr> <chr>    <chr>   
 1 tsunoda         9     1     17:17:42 25.659  
 2 raikkonen       10    1     17:19:14 26.174  
 3 gasly           13    1     17:23:37 25.630  
 4 giovinazzi      15    1     17:26:54 25.987  
 5 max_verstappen  17    1     17:29:03 25.300  
 6 russell         17    1     17:30:00 26.121  
 7 hamilton        18    1     17:30:21 25.235  
 8 latifi          18    1     17:31:31 25.811  
 9 perez           19    1     17:32:28 25.419  
10 mick_schumacher 22    1     17:37:38 25.881  
# … with 20 more rows
```

