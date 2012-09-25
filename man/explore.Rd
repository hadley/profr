\name{explore}
\alias{explore}
\title{Interactively explore profiling results.}
\usage{
  explore(df)
}
\description{
  Interactively explore profiling results.
}
\details{
  Interaction:

  \itemize{ \item Hover to see function name, and highlight
  all calls to that function \item Click on a call to
  zoom-in, and show only calls beneath that call \item
  Click on empty space to zoom back out. }
}
\examples{
reshape_ex <- system.file("samples", "reshape.rprof", package="profr")
if (require("qtbase")) {
   explore(parse_rprof(reshape_ex))
}
}
\author{
  Garrett Grolemund, Hadley Wickham
}

