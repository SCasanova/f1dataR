#' Dark F1-style Theme for ggplot
#'
#' Theme for all f1dataR plot functions. Mimics Formula 1 style.
#'
#' @param axis_marks True or false, whether axis line, ticks and title should
#' be shown or not. Defaults to false
#' @importFrom magrittr "%>%"
#' @return A ggplot object that indicates grand prix, driver, time and selected
#' color variable.
#' @export


theme_dark_f1 <- function(axis_marks = FALSE) {
  if (axis_marks) {
    ggplot2::theme_gray() +
      ggplot2::theme(
        panel.grid = ggplot2::element_blank(),
        axis.line = ggplot2::element_line(colour = "white"),
        axis.text = ggplot2::element_text(colour = "white"),
        axis.title = ggplot2::element_text(colour = "white"),
        axis.ticks = ggplot2::element_line(colour = "white"),
        plot.title  = ggplot2::element_text(face = "bold", size = 17, color = "#cf1b1f"),
        plot.subtitle  = ggplot2::element_text(face = "bold", size = 14),
        plot.background = ggplot2::element_rect(fill = "grey10"),
        panel.background = ggplot2::element_blank(),
        legend.background = ggplot2::element_blank(),
        legend.key = ggplot2::element_blank(),
        plot.caption = ggplot2::element_text(size = 8, color = "white"),
        text = ggplot2::element_text(color = "white")
      )
  } else {
    ggplot2::theme_gray() +
      ggplot2::theme(
        panel.grid = ggplot2::element_blank(),
        axis.line = ggplot2::element_blank(),
        axis.text = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        plot.title  = ggplot2::element_text(face = "bold", size = 17, color = "#cf1b1f"),
        plot.subtitle  = ggplot2::element_text(face = "bold", size = 14),
        plot.background = ggplot2::element_rect(fill = "grey10"),
        panel.background = ggplot2::element_blank(),
        legend.background = ggplot2::element_blank(),
        legend.key = ggplot2::element_blank(),
        plot.caption = ggplot2::element_text(size = 8, color = "white"),
        text = ggplot2::element_text(color = "white")
      )
  }

}
