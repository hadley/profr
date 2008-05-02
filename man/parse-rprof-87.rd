\name{parse_rprof}
\alias{parse_rprof}
\title{Parse Rprof output}
\author{Hadley Wickham <h.wickham@gmail.com>}

\description{
Parses the output of \code{\link{Rprof}} into an alternative format described in \code{\link{profr}}.
}
\usage{parse_rprof(path, interval=0.02)}
\arguments{
\item{path}{}
\item{interval}{}
}
\value{\code{\link{data.frame}} of class \code{profr}}
\details{This produces a flat data frame, which is somewhat easier to summarise
and visualise.}
\seealso{\code{\link{profr}} for profiling and parsing}
\examples{nesting <- parse_rprof(system.file("samples", "nesting.rprof", package="profr"))
diamonds <- parse_rprof(system.file("samples", "reshape.rprof", package="profr"))}
\keyword{debugging}
