#' Load Constructor Info
#'
#' @description Loads info for all constructors that have ever participated in Formula 1.
#'
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with one row per constructor, with columns `constructor_id`, `name`,
#' and `nationality` (all character). Returns `NULL` on API failure.
load_constructors <- function() {
  lim <- 100
  url <- "constructors.json"
  parameters <- list(limit = lim)
  data <- get_jolpica_content(url, parameters)

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$ConstructorTable$Constructors

  # Iterate over the request until completed
  while (nrow(full) < total) {
    offset <- offset + lim

    parameters <- list(limit = lim, offset = offset)
    data <- get_jolpica_content(url, parameters)

    if (is.null(data)) {
      return(NULL)
    }

    full <- dplyr::bind_rows(full, data$MRData$ConstructorTable$Constructors)
  }

  return(
    full %>%
      dplyr::select("constructorId", "name", "nationality") %>%
      tibble::as_tibble() %>%
      janitor::clean_names()
  )
}
