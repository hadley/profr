#' Visualise profiling data with base graphics.
#' Visualise profiling data stored in a \code{profr} data.frame.
#'
#' If you only want a small part of the total call tree, you will need
#' to subset the object as demonstrated by the example.
#'
#' @param x profile output to plot
#' @param ... other arguments passed on to \code{\link{plot.default}}
#' @param minlabel minimum percent of time for function to get a label
#' @param angle function label angle
#' @keywords hplot
#' @seealso \code{\link{ggplot.profr}}
#' @export
#' @examples
#' plot(nesting_prof)
#' plot(reshape_prof)
plot.profr <- function(x, ..., minlabel = 0.1, angle = 0) {
  graphics::plot(1,1, xlim=range(x$start, x$end), ylim=range(x$level)+c(-0.5, 0.5), type="n", ..., xlab="time", ylab="level")
  graphics::rect(x$start, x$level - 0.5, x$end, x$level +0.5, ...)

  time <- NULL # quiet R CMD check note
  labels <- subset(x, time > max(time) * minlabel)

  if (nrow(labels) > 0)
    graphics::text(labels$start, labels$level, labels$f, pos=4, srt=angle, ...)
}

#' Visualise profiling data with ggplot2.
#' Visualise profiling data stored in a \code{profr} data.frame.
#'
#' This will plot the call tree of the specified stop watch object.
#' If you only want a small part, you will need to subset the object
#'
#' @param data profile output to plot
#' @param ... other arguments passed on to \code{\link[ggplot2]{ggplot}}
#' @param minlabel minimum percent of time for function to get a label
#' @param angle function label angle
#' @seealso \code{\link{plot.profr}}
#' @keywords hplot
#' @rawNamespace
#' if (getRversion() >= "3.6.0") {
#'   S3method(ggplot2::ggplot, "profr", ggplot.profr)
#' } else {
#'   export(ggplot.profr)
#' }
#' @examples
#' if (require("ggplot2")) {
#'   ggplot(nesting_prof)
#'   ggplot(reshape_prof)
#' }
ggplot.profr <- function(data, ..., minlabel = 0.1, angle=0) {
  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Please install ggplot2 to use this plotting method")
  data$range <- diff(range(data$time))

  # quiet R CMD check note
  start <- NULL
  end <- NULL
  time <- NULL

  ggplot2::ggplot(as.data.frame(data)) +
    ggplot2::geom_rect(
      ggplot2::aes(xmin = start, xmax = end, ymin = level - 0.5, ymax = level + 0.5),
      fill = "grey95", colour = "black", size = 0.5) +
    ggplot2::geom_text(
      ggplot2::aes(start + range / 60, level, label = f),
      data = subset(data, time > max(time) * minlabel),
      size = 4, angle = angle, hjust = 0) +
    ggplot2::scale_y_continuous("time") +
    ggplot2::scale_x_continuous("level")
}

globalVariables(c("f", "level", "leaf"))
