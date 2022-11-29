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
