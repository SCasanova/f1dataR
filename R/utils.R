#' Get Ergast Content
#'
#' @description Gets ergast content and returns the processed json object if
#' no Ergast errors are found.
#'
#' @param url the complete Ergast URL to get
#'
#' @return the result of `jsonlite::fromJSON` called on ergast's return content
get_ergast_content<-function(url){
  res <- httr::GET(url)

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
#'
#' @return Year (four digit number) representation of current season, as numeric.
.get_current_season<-function(){
  tryCatch({
    url <- glue::glue('http://ergast.com/api/f1/current.json?limit=30')
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
#'
#' @export
#' @return Year (four digit number) representation of current season, as numeric.
get_current_season <- memoise::memoise(.get_current_season)
