#' Get Ergast Content
#'
#' @description Gets ergast content and returns the processed json object if
#' no Ergast errors are found.
#'
#' @param url the complete Ergast URL to get
#' @keyword internal
#' @return the result of `jsonlite::fromJSON` called on ergast's return content

get_ergast_content<-function(url){
  fullurl<-glue::glue("https://ergast.com/api/f1/{url}", url = url)
  res <- httr::GET(fullurl,
                   httr::user_agent(glue::glue("f1dataR/{ver}", ver = installed.packages()['f1dataR','Version'])))

  #Handle Ergast errors with more informative error codes.
  if(res$status_code != 200 | rawToChar(res$content) == "Unable to select database"){
    message('Failure at Ergast with https:// connection. Retrying as http://.')
    # Try revert to not https mode
    fullurl<-glue::glue("http://ergast.com/api/f1/{url}", url = url)
    res <- httr::GET(fullurl,
                     httr::user_agent(glue::glue("f1dataR/{ver}", ver = installed.packages()['f1dataR','Version'])))
  }


  #Handle Ergast errors with more informative error codes.
  if(res$status_code != 200){
    stop(glue::glue("Error getting Ergast Data, http status code {code}.",
                    code = res$status_code))
  }
  if(rawToChar(res$content) == "Unable to select database"){
    stop("Ergast is having database trouble. Please try again at a later time.")
  }

  #presuming ergast is ok...
  return(jsonlite::fromJSON(rawToChar(res$content)))
}

#' Get Current Season core
#'
#' @description Looks up current season from ergast, fallback to manual determination
#' @keyword internal
#' @return Year (four digit number) representation of current season, as numeric.
.get_current_season<-function(){
  tryCatch({
    url <- glue::glue('current.json?limit=30')
    data <- get_ergast_content(url)
    current_season <- as.numeric(data$MRData$RaceTable$season)
  },
  error = function(e){
    message("f1dataR: Error getting current season from ergast", e)
    message("Falling back to manually determined 'current' season")
    current_season <- ifelse(as.numeric(strftime(Sys.Date(), "%m"))<3,
                             as.numeric(strftime(Sys.Date(), "%Y"))-1,
                             as.numeric(strftime(Sys.Date(), "%Y")))
  })
  return(current_season)
}

#' Get Current Season
#'
#' @description Looks up current season from ergast, fallback to manual determination
#' @keyword internal
#' @export
#' @return Year (four digit number) representation of current season, as numeric.

get_current_season <- memoise::memoise(.get_current_season)


.get_fastf1_version <- function(){
  ver<-reticulate::py_list_packages() %>%
    dplyr::filter(.data$package == "fastf1") %>%
    dplyr::pull("version")
  if(length(ver) == 0){
    message("Ensure fastf1 python package is installed.\nPlease run this to install the most recent version:\nreticulate::py_install('fastf1')")
    return(NA)
  }
  if(as.integer(substr(ver, start = 1, 1)) >= 3){
    return(3)
  } else if(as.integer(substr(ver, start = 1, 1)) <= 2){
    message("The Python package fastf1 was updated to v3 recently.\nPlease update the version on your system by running:\nreticulate::py_install('fastf1')\nFuture versions of f1dataR may not support fastf1 < v3.0.0")
    return(2)
  } else {
    return(NA)
  }
}

get_fastf1_version <- memoise::memoise(.get_fastf1_version)
