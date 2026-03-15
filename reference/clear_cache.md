# Clear f1dataR Cache

Clears the cache for f1dataR telemetry and Jolpica API results. Note
that the cache directory can be set by setting
`option(f1dataR.cache = [cache dir])`, but the default is a temporary
directory.

You can also call the alias `clear_cache()` for the same result

## Usage

``` r
clear_f1_cache()

clear_cache()
```

## Value

No return value, called to erase cached data

## Examples

``` r
if (FALSE) { # \dontrun{
clear_f1_cache()
} # }
```
