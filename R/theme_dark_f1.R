#' Dark F1-style Theme for ggplot
#'
#' Theme for all f1dataR plot functions. Mimics Formula 1 style.
#'
#' @param season number from 2018 to 2022 (defaults to current season).
#' @param race number from 1 to 23 (depending on season selected) and defaults
#' to most recent.
#' @param driver three letter driver code (see load_drivers() for a list)
#' @param color argument that indicates which variable to plot overtop the
#' circuit
#' @importFrom magrittr "%>%"
#' @return A ggplot object that indicates grand prix, driver, time and selected
#' color variable.
#' @export


theme_dark_f1 <- function(){
  ggplot2::theme_gray()+
      ggplot2::theme(
        panel.grid = ggplot2::element_blank(),
        axis.line = ggplot2::element_blank(),
        axis.text = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        plot.title  = ggplot2::element_text(face = 'bold', size = 17, color = '#cf1b1f'),
        plot.subtitle  = ggplot2::element_text(face = 'bold', size = 14),
        plot.background = ggplot2::element_rect(fill = "grey10"),
        panel.background = ggplot2::element_blank(),
        legend.background = ggplot2::element_blank(),
        legend.key = ggplot2::element_blank(),
        plot.caption = ggplot2::element_text(size = 8, color = 'white'),
        text = ggplot2::element_text(color = 'white')
      )
}
