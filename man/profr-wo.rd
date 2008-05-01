\name{profr}
\alias{profr}
\title{profr}
\author{Hadley Wickham <h.wickham@gmail.com>}

\description{
Profile the performance of function call.
}
\usage{profr(expr, interval = 0.02, quiet = TRUE)}
\arguments{
\item{expr}{expression to profile}
\item{interval}{interval between samples (in seconds)}
\item{quiet}{should output be discarded?}
}
\value{\code{\link{data.frame}} of class \code{profr}}
\details{This is a wrapper around \code{\link{Rprof}} that provides results in an
alternative data structure, a data.frame.  The columns of the data.frame
are:

\describe{
\item{f}{name of function}
\item{level}{level in call stack}
\item{time}{total time (seconds) spent in function}
\item{start}{time at which control entered function}
\item{end}{time at which control exited function}
\item{leaf}{\code{TRUE} if the function is a terminal node in the call tree, i.e. didn't call any other functions}
\item{source}{guess at the package that the function came from}
}}
\seealso{\code{\link{parse_rprof}} to parse standalone \code{\link{Rprof}} file, \code{\link{plot.profr}} and \code{\link{ggplot.profr}} to visualise the profiling data}
\examples{glm_ex <- profr(example(glm))
head(glm_ex)
summary(glm_ex)
plot(glm_ex)}
\keyword{debugging}
