#' Load Circuit Info
#'
#' @description Loads circuit info for all circuits in a given season. Use `.load_circuits()`
#' for an uncached version of this function
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @export
#' @return A tibble with one row per circuit
load_circuits <- function(season = get_current_season()) {
  if (season != "current" && (season < 1950 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 1950 and {get_current_season()} (or use "current")')
  }

  url <- glue::glue("{season}/circuits.json?limit=40",
    season = season
  )

  data <- get_jolpica_content(url)

  if (is.null(data)) {
    return(NULL)
  }

  data$MRData$CircuitTable$Circuits %>%
    tidyr::unnest(cols = c("Location")) %>%
    dplyr::select(
      "circuitId",
      "circuitName",
      "lat":"country"
    ) %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
}
