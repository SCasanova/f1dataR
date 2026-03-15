# Add Column if Absent

Adds a column (with the name specified in column_name) of NA values to a
data.frame or tibble. If that column already exists, no change will be
made to data. NA value type (character, integer, real, logical) may be
specified.

## Usage

``` r
add_col_if_absent(data, column_name, na_type = NA)
```

## Arguments

- data:

  a data.frame or tibble to which a column may be added

- column_name:

  the name of the column to be added if it doesn't exist

- na_type:

  the type of NA value to use for the column values. Default to basic
  `NA`

## Value

the data.frame as provided (converted to tibble)
