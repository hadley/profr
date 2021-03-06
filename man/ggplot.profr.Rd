% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/output.r
\name{ggplot.profr}
\alias{ggplot.profr}
\title{Visualise profiling data with ggplot2.
Visualise profiling data stored in a \code{profr} data.frame.}
\usage{
ggplot.profr(data, ..., minlabel = 0.1, angle = 0)
}
\arguments{
\item{data}{profile output to plot}

\item{...}{other arguments passed on to \code{\link[ggplot2]{ggplot}}}

\item{minlabel}{minimum percent of time for function to get a label}

\item{angle}{function label angle}
}
\description{
This will plot the call tree of the specified stop watch object.
If you only want a small part, you will need to subset the object
}
\examples{
if (require("ggplot2")) {
  ggplot(nesting_prof)
  ggplot(reshape_prof)
}
}
\seealso{
\code{\link{plot.profr}}
}
\keyword{hplot}
