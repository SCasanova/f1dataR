#' Load Constructor Info
#'
#' @description Loads constructor info for all participants in a given season.
#' Use `.load_constructors()`for an uncached version of this function
#'
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with one row per constructor
load_constructors <- function() {
  url <- "constructors.json?limit=300"
  data <- get_ergast_content(url)

  if(is.null(data)){
    return(NULL)
  }

  return(data$MRData$ConstructorTable$Constructors %>%
    dplyr::select("constructorId", "name", "nationality") %>%
    janitor::clean_names())
}
