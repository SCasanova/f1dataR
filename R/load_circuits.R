#' Load Circuit Info
#'
#' @description Loads circuit info for all circuits in a given season.
#'
#' @param season number from 1950 to current season, or `"current"` (defaults to current season).
#' @export
#' @return A tibble with one row per circuit. Returns `NULL` on API failure.
load_circuits <- function(season = get_current_season()) {
  check_season_arg(season, 1950)

  url <- glue::glue("{season}/circuits.json", season = season)

  lim <- 100
  data <- get_jolpica_content(url, parameters = list(limit = lim))

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$CircuitTable$Circuits

  # Iterate over the request until completed
  while (nrow(full) < total) {
    offset <- offset + lim

    data <- get_jolpica_content(
      url,
      parameters = list(limit = lim, offset = offset)
    )

    if (is.null(data)) {
      return(NULL)
    }

    full <- dplyr::bind_rows(full, data$MRData$CircuitTable$Circuits)
  }

  full %>%
    tidyr::unnest(cols = c("Location")) %>%
    dplyr::select(
      "circuitId",
      "circuitName",
      "lat":"country"
    ) %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
}
