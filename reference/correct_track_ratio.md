# Correct Track Ratios

Correct Track Ratios helps ensure that ggplot objects are plotted with
1:1 unit ratio. Without this function, plots have different x & y ratios
and the tracks come out misshapen. This is particularly evident at long
tracks like Saudi Arabia or Canada.

Note that this leaves the plot object on a dark background, any plot
borders will be maintained

## Usage

``` r
correct_track_ratio(trackplot, x = "x", y = "y", background = "grey10")
```

## Arguments

- trackplot:

  A GGPlot object, ideally showing a track layout for ratio correction

- x, y:

  Names of columns in the original data used for the plot's x and y
  values. Defaults to 'x' and 'y'

- background:

  Background colour to use for filling out the plot edges. Defaults to
  `"grey10"` which is the default background colour if you use
  [`theme_dark_f1()`](https://scasanova.github.io/f1dataR/reference/theme_dark_f1.md)
  to theme your plots.

## Value

a ggplot object with
[`ggplot2::scale_x_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)
and
[`ggplot2::scale_y_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)
set to the same limits to produce an image with shared x and y limits
and with
[`ggplot2::coord_fixed()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html)
set.

## Examples

``` r
if (FALSE) { # \dontrun{
# Note that plot_fastest plots have already been ratio corrected
fast_plot <- plot_fastest(season = 2022, round = 1, session = "Q", driver = V)
correct_track_ratio(fast_plot)
} # }
```
