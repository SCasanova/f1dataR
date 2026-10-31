#' Load Driver Info
#'
#' @description Loads driver info for all participants in a given season.
#'
#' @param season number from 1950 to current season, or `"current"` (defaults to current season).
#' @importFrom magrittr "%>%"
#' @export
#' @return A tibble with columns `driver_id` (unique and recurring), `given_name`,
#' `family_name`, `nationality`, `date_of_birth` (yyyy-mm-dd format), `code` (driver code), and
#' `permanent_number` (for post-2014 drivers). Returns `NULL` on API failure. Note that
#' `permanent_number` is returned by the API as a **character** column when present (and is
#' `NA_integer_` when absent for a given driver), so its type is not stable across seasons;
#' coerce with `as.integer()` if a consistent numeric type is required.
load_drivers <- function(season = get_current_season()) {
  check_season_arg(season, 1950)

  url <- glue::glue("{season}/drivers.json", season = season)

  lim <- 100
  data <- get_jolpica_content(url, parameters = list(limit = lim))

  if (is.null(data)) {
    return(NULL)
  }

  total <- data$MRData$total %>% as.numeric()
  offset <- data$MRData$offset %>% as.numeric()

  full <- data$MRData$DriverTable$Drivers

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

    full <- dplyr::bind_rows(full, data$MRData$DriverTable$Drivers)
  }

  data <- full

  data <- add_col_if_absent(data, "code", NA_character_)
  data <- add_col_if_absent(data, "permanentNumber", NA_integer_)

  data %>%
    dplyr::select(
      "driverId",
      "givenName",
      "familyName",
      "nationality",
      "dateOfBirth",
      "code",
      "permanentNumber"
    ) %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
}
