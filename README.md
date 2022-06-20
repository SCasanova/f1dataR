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
and round. Round refers to race number. The defaults are current season and last race.

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


