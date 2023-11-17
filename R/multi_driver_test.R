library(tidyverse)
library(f1dataR)

# multi_driver <- function(season, round, drivers, laps = 'fastest'){
#   data <- tibble(
#     driver = drivers,
#     round = round,
#     season = season
#   )
#   load_race_session(obj_name = "session", season = season, round = round, session = 'R')
#   reticulate::py_run_string("session.load()")
#   
#   get_driver <- function(season, round, driver, laps = 'fastest'){
#     reticulate::py_run_string(glue::glue("tel = session.laps.pick_driver('{driver}').pick_fastest().get_telemetry().add_distance(){opt}",
#                                          driver = driver, opt = ''
#     ))
#     py_env <- reticulate::py_run_string(paste("tel.SessionTime = tel.SessionTime.dt.total_seconds()",
#                                               "tel.Time = tel.Time.dt.total_seconds()",
#                                               sep = "\n"
#     ))
#     
#     tel <- reticulate::py_to_r(reticulate::py_get_item(py_env, "tel"))
#     
#     tel %>%
#       dplyr::mutate(driverCode = driver) %>%
#       tibble::tibble() %>%
#       janitor::clean_names()
#   }
#   
#   mapply(get_driver, data$season, data$round, data$driver)%>% 
#     t() %>% 
#     data.frame() %>% 
#     unnest(cols = c(date, session_time, driver_ahead,
#                     distance_to_driver_ahead, time, rpm, speed, n_gear, throttle, brake, drs,
#                     source, relative_distance, status, x, y, z, distance, driver_code))
# }
# 
# personalfix::time_check({
#   multi_driver(2023,1,c('LEC', 'VER')) 
# })
# 
# personalfix::time_check({
#   multi_driver(2023,1,c('LEC', 'VER', 'BOT', 'PER', 'SAI', 'SAR', 'ALB')) 
# })


multi_driver_parallel <- function(season, round, drivers, laps = 'fastest'){
  data <- tibble(
    driver = drivers,
    round = round,
    season = season
  )
  load_race_session(obj_name = "session", season = season, round = round, session = 'R')
  reticulate::py_run_string("session.load()")
  
  get_driver <- function(season, round, driver, laps = 'fastest'){
    reticulate::py_run_string(glue::glue("tel = session.laps.pick_driver('{driver}').pick_fastest().get_telemetry().add_distance(){opt}",
                                         driver = driver, opt = ''
    ))
    py_env <- reticulate::py_run_string(paste("tel.SessionTime = tel.SessionTime.dt.total_seconds()",
                                              "tel.Time = tel.Time.dt.total_seconds()",
                                              sep = "\n"
    ))
    
    tel <- reticulate::py_to_r(reticulate::py_get_item(py_env, "tel"))
    
    tel %>%
      dplyr::mutate(driverCode = driver) %>%
      tibble::tibble() %>%
      janitor::clean_names()
  }
  
  parallel::mcmapply(get_driver, data$season, data$round, data$driver, mc.cores=parallel::detectCores()-1)%>% 
    t() %>% 
    data.frame() %>% 
    unnest(cols = c(date, session_time, driver_ahead,
                    distance_to_driver_ahead, time, rpm, speed, n_gear, throttle, brake, drs,
                    source, relative_distance, status, x, y, z, distance, driver_code))
}

personalfix::time_check({
  multi_driver_parallel(2023,1,c('LEC', 'VER')) 
})

personalfix::time_check({
  multi_driver_parallel(2023,1,c('LEC', 'VER', 'BOT', 'PER', 'SAI', 'SAR', 'ALB')) 
})


