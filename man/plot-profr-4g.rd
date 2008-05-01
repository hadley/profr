\name{plot.profr}
\alias{plot.profr}
\title{Visualise profiling data with base graphics}
\author{Hadley Wickham <h.wickham@gmail.com>}

\description{
Visualise profiling data stored in a \code{profr} data.frame.
}
\usage{plot.profr(x, ..., minlabel = 0.1, angle = 0)}
\arguments{
\item{x}{profile output to plot}
\item{...}{other arguments passed on to \code{\link{plot.default}}}
\item{minlabel}{minimum percent of time for function to get a label}
\item{angle}{function label angle}
}

\details{If you only want a small part of the total call tree, you will need
to subset the object as demonstrated by the example.}
\seealso{\code{\link{ggplot.profr}}}
\examples{glm_ex <- profr(example(glm))
plot(glm_ex)
plot(subset(glm_ex, level < 5))}
\keyword{hplot}
