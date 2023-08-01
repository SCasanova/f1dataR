# Vignettes that depend on internet access have been precompiled
# Per guidance in:
# https://ropensci.org/blog/2019/12/08/precompute-vignettes/#the-solution-locally-knitting-rmarkdown
# Must manually move figures from package root ./ to ./vignettes

knitr::knit("vignettes/ergast-data-analysis.Rmd.orig", "vignettes/ergast-data-analysis.Rmd")
knitr::knit("vignettes/introduction.Rmd.orig", "vignettes/introduction.Rmd")
cat("Successfully compiled vignettes. Please move ./figure to ./vignettes/figure")

# Optional
# devtools::build_vignettes()
