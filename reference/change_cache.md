# Change Caching Settings

Change caching settings for the package. By default, the cache will be
set to keep the results of function calls in memory to reduce the number
of requests made to online services for the same data. However, if
preferred, the cache can be set to a file directory to make the results
persist between sessions.

This is a particularly good idea if you're using functions like
[`load_driver_telemetry()`](https://scasanova.github.io/f1dataR/reference/load_driver_telemetry.md),
[`load_session_laps()`](https://scasanova.github.io/f1dataR/reference/load_session_laps.md),
[`load_race_session()`](https://scasanova.github.io/f1dataR/reference/load_race_session.md)
or
[`plot_fastest()`](https://scasanova.github.io/f1dataR/reference/plot_fastest.md)
as they take significant time and download large amounts of data each
time you run the function.

If preferred for testing or waiting for data updates on race weekends,
you may wish to set the cache to `'off'` instead.

Changes to cache can be made for the session (mark the argument
`persist` as `FALSE`) or apply to the next session(s) by setting
`persist` to `TRUE`

## Usage

``` r
change_cache(cache = "memory", create_dir = FALSE, persist = FALSE)
```

## Arguments

- cache:

  One of `'memory'`, `'filesystem'`, `'off'` or a directory.

  If the selection is `'filesystem'` the package will automatically
  write the cache to the operating system's default location for
  permanent or temporary caches (see `persist`)

- create_dir:

  Whether to create the directory if it doesn't already exist if a path
  cache directory is provided. By default this doesn't occur for
  provided cache paths, but will always happen if the cache choice is
  set to `'filesystem'`.

- persist:

  Whether to make this change permanent (`TRUE`) or a temporary cache
  change only (default, `FALSE`). Note if you set `cache` to `'off'` and
  `persist` to `TRUE` the existing cache will be cleared by calling
  [`clear_cache()`](https://scasanova.github.io/f1dataR/reference/clear_cache.md).

  If `filesystem` is chosen for `cache` and `persist` is set to `TRUE`,
  then a cache directory will be placed in the default location for the
  operating system. If instead `persist` is set to `FALSE`, then a
  temporary directory will be used instead, and this will be removed at
  the end of the session. This essentially has the same effect as having
  `cache` set to `'memory'`.

## Value

No return, called for side effects

## Examples

``` r
if (FALSE) { # \dontrun{
change_cache("~/f1dataRcache", create_dir = TRUE)

change_cache("off", persist = FALSE)
} # }
```
