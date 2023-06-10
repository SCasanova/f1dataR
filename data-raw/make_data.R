driver_constructor_data <- readr::read_csv('data-raw/driver_constructor_data.csv')

usethis::use_data(driver_constructor_data, overwrite = T)
