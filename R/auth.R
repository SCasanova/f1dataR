#' Check F1 Authentication Credentials
#'
#' @description Since October 2026, F1 live timing (accessed through `FastF1`) requires an F1 account.
#' `FastF1` reads credentials from the `F1_USERNAME` and `F1_PASSWORD` environment variables. This checks
#' that both are set (not that they are valid). If they are missing, an interactive session is prompted
#' via [set_f1_auth()], and a non-interactive session errors.
#'
#' @return invisibly `TRUE`
#'
#' @keywords internal
check_ff1_auth <- function() {
  if (nzchar(Sys.getenv("F1_USERNAME")) && nzchar(Sys.getenv("F1_PASSWORD"))) {
    return(invisible(TRUE))
  }

  if (rlang::is_interactive()) {
    cli::cli_alert_warning(
      "F1 account credentials are required to access F1 live timing data."
    )
    set_f1_auth()
    return(invisible(TRUE))
  }

  cli::cli_abort(c(
    "F1 live timing requires authentication.",
    x = "Environment variables {.envvar F1_USERNAME} and {.envvar F1_PASSWORD} must both be set.",
    i = "Set them in {.file ~/.Renviron}, or run {.fn set_f1_auth} in an interactive session.",
    i = "See {.url https://docs.fastf1.dev/api_reference/accounts_auth.html}."
  ))
}


#' Set F1 Account Credentials
#'
#' @description Since October 2026, F1 live timing data (accessed through `FastF1`) requires an F1 account.
#' This function stores your credentials in the `F1_USERNAME` and `F1_PASSWORD` environment variables, which
#' `FastF1` reads. The values are always set for the current R session. Optionally they are also saved in your
#' user `.Renviron` file so they are available in future sessions.
#'
#' Only the password authentication method of `FastF1` is supported.
#'
#' @details
#' With `persist = TRUE` the password is stored in plain text in your `.Renviron` file (located by
#' `R_ENVIRON_USER` or `~/.Renviron`). The file permissions are restricted to the current user where
#' supported. On shared machines consider setting the variables another way.
#'
#' @param username F1 account email. If `NULL`, you are prompted (interactive sessions only).
#' @param password F1 account password. If `NULL`, you are prompted without echo using [askpass::askpass()]
#' (interactive sessions only).
#' @param persist Whether to also save the credentials to your `.Renviron` file. Default `FALSE`. Note that
#' password will be stored in plain text in your `.Renviron` file if `persist = TRUE`.
#'
#' @return invisibly `TRUE`
#' @export
#' @examples
#' if (interactive()) {
#'   set_f1_auth()
#' }
set_f1_auth <- function(username = NULL, password = NULL, persist = FALSE) {
  if (!rlang::is_interactive() && (is.null(username) || is.null(password))) {
    cli::cli_abort(
      "{.arg username} and {.arg password} must be provided in a non-interactive session."
    )
  }

  if (is.null(username)) {
    username <- trimws(readline("F1 account email: "))
  }
  if (is.null(password)) {
    password <- askpass::askpass("F1 account password: ")
  }

  if (
    !is.character(username) ||
      length(username) != 1 ||
      !nzchar(username) ||
      !is.character(password) ||
      length(password) != 1 ||
      !nzchar(password)
  ) {
    cli::cli_abort(
      "A non-empty {.arg username} and {.arg password} are required."
    )
  }

  Sys.setenv(F1_USERNAME = username, F1_PASSWORD = password)

  if (isTRUE(persist)) {
    write_renviron(c(F1_USERNAME = username, F1_PASSWORD = password))
    cli::cli_alert_success(
      "Credentials set for this session and saved to {.file {renviron_path()}}."
    )
  } else {
    cli::cli_alert_success("Credentials set for this session.")
  }

  invisible(TRUE)
}


#' Path of the user .Renviron file
#' @noRd
renviron_path <- function() {
  path <- Sys.getenv("R_ENVIRON_USER")
  if (!nzchar(path)) {
    path <- file.path(Sys.getenv("HOME"), ".Renviron")
  }
  path
}


#' Upsert variables in the user .Renviron file, preserving other lines
#' @param vars named character vector
#' @noRd
write_renviron <- function(vars) {
  path <- renviron_path()
  lines <- if (file.exists(path)) {
    readLines(path, warn = FALSE)
  } else {
    character(0)
  }

  for (nm in names(vars)) {
    # Quote and escape so special characters survive R's .Renviron parsing
    value <- gsub("\\", "\\\\", vars[[nm]], fixed = TRUE)
    value <- gsub("\"", "\\\"", value, fixed = TRUE)
    new_line <- sprintf("%s=\"%s\"", nm, value)
    idx <- grep(paste0("^\\s*", nm, "\\s*="), lines)
    if (length(idx) > 0) {
      lines[idx[1]] <- new_line
      if (length(idx) > 1) lines <- lines[-idx[-1]]
    } else {
      lines <- c(lines, new_line)
    }
  }

  writeLines(lines, path)
  Sys.chmod(path, mode = "0600")
  invisible(path)
}
