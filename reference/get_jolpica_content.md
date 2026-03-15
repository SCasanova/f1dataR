# Get Jolpica Content

Gets Jolpica-F1 content and returns the processed json object if no
errors are found. This will automatically fall back from https:// to
http:// if Jolpica suffers errors, and will automatically retry up to 5
times by each protocol

Note in 2024 this replaced the deprecated Ergast API. Much of the
historical data is duplicated in Jolpica

## Usage

``` r
get_jolpica_content(url, parameters = list(limit = 40))
```

## Arguments

- url:

  the Jolpica URL tail to get from the API (for example,
  `"{season}/circuits.json?limit=40"` is called from
  [`load_circuits()`](https://scasanova.github.io/f1dataR/reference/load_circuits.md)).

- parameters:

  Parameters to add to the url. Typically `"...?limit=40"`.

## Value

the result of
[`jsonlite::fromJSON`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
called on Jolpica's return content. Further processing is performed by
specific functions
