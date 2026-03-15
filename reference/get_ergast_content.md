# Get Ergast Content

Gets Ergast content and returns the processed json object if no Ergast
errors are found. This will automatically fall back from https:// to
http:// if Ergast suffers errors, and will automatically retry up to 5
times by each protocol

**\[deprecated\]**

Note the Ergast Motor Racing Database API will shut down at the end of
2024. This function willbe replaced with a new data-source when one is
made available.

## Usage

``` r
get_ergast_content(url)
```

## Arguments

- url:

  the Ergast URL tail to get from the API (for example,
  `"{season}/circuits.json?limit=40"` is called from
  [`load_circuits()`](https://scasanova.github.io/f1dataR/reference/load_circuits.md)).

## Value

the result of
[`jsonlite::fromJSON`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
called on Ergast's return content. Further processing is performed by
specific functions
