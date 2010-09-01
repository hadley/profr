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
#' @method plot profr
#' @S3method plot profr
#' @examples
#' plot(nesting_prof)
#' plot(reshape_prof)
plot.profr <- function(x, ..., minlabel = 0.1, angle = 0) {
  plot(1,1, xlim=range(x$start, x$end), ylim=range(x$level)+c(-0.5, 0.5), type="n", ..., xlab="time", ylab="level")
  rect(x$start, x$level - 0.5, x$end, x$level +0.5, ...)
  labels <- subset(x, time > max(time) * minlabel)
  if (nrow(labels) > 0)
    text(labels$start, labels$level, labels$f, pos=4, srt=angle, ...)
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
#' @method   ggplot profr
#' @S3method ggplot profr
#' @examples
#' if (require("ggplot2", quiet = TRUE)) {
#'  ggplot(nesting_prof)
#'  ggplot(reshape_prof)
#' }
ggplot.profr <- function(data, ..., minlabel = 0.1, angle=0) {
  if (!require("ggplot2", quiet=TRUE)) stop("Please install ggplot2 to use this plotting method")
  data$range <- diff(range(data$time))
  
  ggplot(as.data.frame(data), aes(x = factor(level))) + 
  geom_bar(aes(min = start, y = end), position="identity", stat = "identity", width = 1, fill="grey95", colour="black", size=0.5) +
  geom_text(aes(label=f, y=start + range/60), data=subset(data, time > max(time) * minlabel), size=4, angle=angle, hjust = 0) +
  scale_y_continuous("time") + scale_x_discrete("level") + 
  coord_flip()
}