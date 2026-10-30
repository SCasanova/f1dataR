# Set F1 Account Credentials

Since October 2026, F1 live timing data (accessed through `FastF1`)
requires an F1 account. This function stores your credentials in the
`F1_USERNAME` and `F1_PASSWORD` environment variables, which `FastF1`
reads. The values are always set for the current R session. Optionally
they are also saved in your user `.Renviron` file so they are available
in future sessions.

Only the password authentication method of `FastF1` is supported.

## Usage

``` r
set_f1_auth(username = NULL, password = NULL, persist = FALSE)
```

## Arguments

- username:

  F1 account email. If `NULL`, you are prompted (interactive sessions
  only).

- password:

  F1 account password. If `NULL`, you are prompted without echo using
  [`askpass::askpass()`](https://r-lib.r-universe.dev/askpass/reference/askpass.html)
  (interactive sessions only).

- persist:

  Whether to also save the credentials to your `.Renviron` file. Default
  `FALSE`. Note that password will be stored in plain text in your
  `.Renviron` file if `persist = TRUE`.

## Value

invisibly `TRUE`

## Details

With `persist = TRUE` the password is stored in plain text in your
`.Renviron` file (located by `R_ENVIRON_USER` or `~/.Renviron`). The
file permissions are restricted to the current user where supported. On
shared machines consider setting the variables another way.

## Examples

``` r
if (interactive()) {
  set_f1_auth()
}
```
