#' Load Constructor Info (not cached)
#'
#' Loads constructor info for all participants in a given season.
#' This function does not export, only the cached version.
#'
#' @importFrom magrittr "%>%"
#' @return A tibble with columns constructorId (unique and recurring),
#' name, and nationality

.load_constructors <- function(){
  url <- glue::glue('http://ergast.com/api/f1/constructors.json?limit=300')
  data <- get_ergast_content(url)

  return(data$MRData$ConstructorTable$Constructors %>%
           dplyr::select("constructorId", "name", "nationality") %>%
           tibble::as_tibble())
}

#' Load Constructor Info
#'
#' Loads constructor info for all participants in a given season.
#' This function does not export, only the cached version.
#'
#' @importFrom magrittr "%>%"
#' @return A tibble with columns constructorId (unique and recurring),
#' name, and nationality

#' @export

load_constructors <- memoise::memoise(.load_constructors)
