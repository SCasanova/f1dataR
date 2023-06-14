#' Load Circuit Info (not cached)
#'
#' Loads circuit info for all circuits in a given season.
#' This function does not export, only the cached version.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @importFrom magrittr "%>%"
#' @keyword internal
#' @return A tibble with one row per circuit

.load_circuits <- function(season = 'current'){
  if(season != 'current' & (season < 1950 | season > get_current_season())){
    stop(glue::glue('Year must be between 1950 and {current} (or use "current")',
                    current=get_current_season()))
  }

  url <- glue::glue('{season}/circuits.json?limit=40',
                    season = season)
  data <- get_ergast_content(url)

  data$MRData$CircuitTable$Circuits %>%
    tidyr::unnest(cols = c("Location")) %>%
    dplyr::select("circuitId",
                  "circuitName",
                  "lat":"country") %>%
    tibble::as_tibble() %>%
    janitor::clean_names()

}

#' Load Ciruit Info
#'
#' Loads Circuit info for all participants in a given season.
#'
#' @param season number from 1950 to current season (defaults to current season).
#' @return A tibble with with one row per circuit

#' @export

load_circuits <- memoise::memoise(.load_circuits)
