# profr
# Profile the performance of function call.
#
# This is basically a wrapper around \link{RProf} that provides
# results in a format that is easier to deal with.  This is a data.frame
# with the following columns: function name, level in call stack,
# start time, end time, whether or not the function is a leaf 
# (doesn't call any other functions) and source of function.
#
# @seealso \code{\link{summary.stopwatch}}, \code{\link{plot.stopwatch}}
# @arguments function to profile
# @arguments interval between samples (in seconds)
# @arguments should output be discarded?
# @value data.frame
# @keyword debugging
#X s <- prof(example(glm))
#X summary(s)
#X head(s)
#X plot(s)
profr <- function(f, interval = 0.02, quiet = TRUE) {
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
	try(force(f))
	Rprof()
	
	parse_rprof(tmp)
} 




