\name{plot.profr}
\alias{plot.profr}
\title{Visualise profiling data with base graphics.}
\usage{\method{plot}{profr} (x, ..., minlabel=0.1, angle=0)}

\description{
  Visualise profiling data with base graphics. Visualise
  profiling data stored in a \code{profr} data.frame.
}

\details{
  If you only want a small part of the total call tree, you
  will need to subset the object as demonstrated by the
  example.
}
\keyword{hplot}
\seealso{\code{\link{ggplot.profr}}}
\arguments{
  \item{x}{profile output to plot}
  \item{...}{other arguments passed on to \code{\link{plot.default}}}
  \item{minlabel}{minimum percent of time for function to get a label}
  \item{angle}{function label angle}
}
\examples{plot(nesting_prof)
plot(reshape_prof)}
