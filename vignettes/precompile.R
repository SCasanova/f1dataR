# Vignettes that depend on internet access have been precompiled
# Per guidance in:
# https://ropensci.org/blog/2019/12/08/precompute-vignettes/#the-solution-locally-knitting-rmarkdown
# Must manually move figures from package root ./ to ./vignettes

# Install optipng for your system to enable auto-compression of png files output by knitr.
# See https://bookdown.org/yihui/rmarkdown-cookbook/optipng.html

knitr::knit("vignettes/ergast-data-analysis.Rmd.orig", "vignettes/ergast-data-analysis.Rmd")
knitr::knit("vignettes/introduction.Rmd.orig", "vignettes/introduction.Rmd")
knitr::knit("vignettes/plotting-turn-info.Rmd.orig", "vignettes/plotting-turn-info.Rmd")
knitr::knit("vignettes/alonso-penalty-2024.Rmd.orig", "vignettes/alonso-penalty-2024.Rmd")
cat("Successfully compiled vignettes. Now moving figures to ./vignettes")

vig_images<-list.files(pattern = "(ergast-data-analysis|introduction|plotting-turn-info|alonso-penalty)-[(a-z)(A-Z)(0-9)_]*-1.png")
file.copy(paste0("./", vig_images),
          paste0("./vignettes/", vig_images), overwrite = T)
unlink(vig_images)
# If you have the optipng tool installed on your system run this to reduce png size
# xfun::optipng("./vignettes/")

# Optional
devtools::build_vignettes()
devtools::build_readme()
