#' Load Constructor Info
#'
#' @description Loads constructor info for all participants in a given season.
#' Use `.load_constructors()`for an uncached version of this function
#'
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with one row per constructor
load_constructors <- function() {
  lim <- 100
  url <- glue::glue("constructors.json?limit={lim}",lim = lim)
  data <- get_jolpica_content(url)

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$ConstructorTable$Constructors

  # Iterate over the request until completed
  while (offset + lim <= total) {
    offset <- offset + lim

    url <- glue::glue("constructors.json?limit={lim}&offset={offset}",
                      lim = lim, offset = offset
    )
    data <- get_jolpica_content(url)

    if (is.null(data)) {
      return(NULL)
    }

    full <- dplyr::bind_rows(full, data$MRData$ConstructorTable$Constructors)
  }

  return(full %>%
    dplyr::select("constructorId", "name", "nationality") %>%
    janitor::clean_names())
}
