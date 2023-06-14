#' Load Constructor Info (not cached)
#'
#' Loads constructor info for all participants in a given season.
#' This function does not export, only the cached version.
#'
#' @importFrom magrittr "%>%"
#' @keywords internal
#' @return A tibble with one row per constructor

.load_constructors <- function(){
  url <- glue::glue('constructors.json?limit=300')
  data <- get_ergast_content(url)

  return(data$MRData$ConstructorTable$Constructors %>%
           dplyr::select("constructorId", "name", "nationality"))
}

#' Load Constructor Info
#'
#' Loads constructor info for all participants in a given season.
#' This function does not export, only the cached version.
#'
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns constructorId (unique and recurring),
#' name, and nationality

#' @export

load_constructors <- memoise::memoise(.load_constructors)
