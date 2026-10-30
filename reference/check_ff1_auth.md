# Check F1 Authentication Credentials

Since October 2026, F1 live timing (accessed through `FastF1`) requires
an F1 account. `FastF1` reads credentials from the `F1_USERNAME` and
`F1_PASSWORD` environment variables. This checks that both are set (not
that they are valid). If they are missing, an interactive session is
prompted via
[`set_f1_auth()`](https://scasanova.github.io/f1dataR/reference/set_f1_auth.md),
and a non-interactive session errors.

## Usage

``` r
check_ff1_auth()
```

## Value

invisibly `TRUE`
