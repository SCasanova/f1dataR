# Check FastF1 Version

This function checks the version of `FastF1` and ensures it's at or
above the minimum supported version for `f1dataR` (currently requires
3.1.0 or better).

This function is a light wrapper around get_fastf1_version()

## Usage

``` r
check_ff1_version()
```

## Value

Invisibly `TRUE` if not raising an error for unsupported `FastF1`
version.
