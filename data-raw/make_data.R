constructor_data <- readr::read_csv("data-raw/constructor_data.csv") %>%
  unique()

usethis::use_data(constructor_data, overwrite = TRUE)
