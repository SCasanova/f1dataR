#' Load Constructor Info
#'
#' Loads constructor info for all participants in a given season. Use `.load_constructors()`for an uncached version of this function
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

#' @inherit .load_constructors title description return
#' @export
#' @examples
#' #Load the list of all constructors who have participated in a F1 race:
#' load_constructors()
load_constructors <- memoise::memoise(.load_constructors)
