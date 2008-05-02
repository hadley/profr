# profr
# Profile the performance of function call.
#
# This is a wrapper around \code{\link{Rprof}} that provides results in an
# alternative data structure, a data.frame.  The columns of the data.frame
# are: 
#
# \describe{
#   \item{f}{name of function}
#   \item{level}{level in call stack}
#   \item{time}{total time (seconds) spent in function}
#   \item{start}{time at which control entered function}
#   \item{end}{time at which control exited function}
#   \item{leaf}{\code{TRUE} if the function is a terminal node in the call tree, i.e. didn't call any other functions}
#   \item{source}{guess at the package that the function came from}
# }
#
# @arguments expression to profile
# @arguments interval between samples (in seconds)
# @arguments should output be discarded?
# @value \code{\link{data.frame}} of class \code{profr}
# @keyword debugging
# @seealso \code{\link{parse_rprof}} to parse standalone \code{\link{Rprof}} file, \code{\link{plot.profr}} and \code{\link{ggplot.profr}} to visualise the profiling data
#X glm_ex <- profr(example(glm))
#X head(glm_ex)
#X summary(glm_ex)
#X plot(glm_ex)
profr <- function(expr, interval = 0.02, quiet = TRUE) {
  #assert(is.positive.integer(reps), "Repetitions (reps) must be a positive integer");
  #assert(is.function(f), "f must be a function");
  
  tmp <- tempfile()
  on.exit(unlink(tmp))
  on.exit(unlink("Rprof.out"), add=T)
  
  if (quiet) {
    sink("/dev/null")
    on.exit(sink(), add=TRUE)
  }
  
  Rprof(tmp, append=TRUE)
  try(force(expr))
  Rprof(NULL)
  
  df <- subset(parse_rprof(tmp, interval), level > 7)
  df$level <- df$level - 7
  df
} 




