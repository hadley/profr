# Stop watch
# Profile the performance of function call.
#
# This is basically a wrapper around \link{RProf} that provides
# results in a format that is easier to deal with.  This is a data.frame
# with the following columns: function name, level in call stack,
# start time, end time, whether or not the function is a leaf 
# (doesn't call any other functions) and source of function.
#
# @seealso \code{\link{print.call.tree}}, \code{\link{plot.call.tree}}
# @arguments function to profile
# @arguments number of times to run
# @arguments interval between samples (in seconds)
# @value data.frame
# @keyword debugging
#X s <- stopwatch(example(glm))
#X summary(s)
#X head(s)
#X plot(s)
stopwatch <- function(f, interval = 0.02) {
	#assert(is.positive.integer(reps), "Repetitions (reps) must be a positive integer");
	#assert(is.function(f), "f must be a function");
	
	tmp <- tempfile()
	on.exit(unlink(tmp))
	on.exit(unlink("Rprof.out"), add=T)
	
	sink("/dev/null")
	on.exit(sink(), add=TRUE)
	Rprof(tmp, append=TRUE)
	try(force(f))
	Rprof()

	lines <- scan(tmp, what="character", sep="\n")
	clean.lines <- lines[-grep("sample\\.interval=",lines)]
	calls <- sapply(clean.lines, strsplit, split=" ", USE.NAMES = FALSE)
	calls <- sapply(calls, rev)
	calls <- sapply(calls, function(x) gsub("\"","", x))
	
	class(calls) <- "call.tree"
	attr(calls, "interval") <- interval
	
	.simplify_all(.compact(calls))
} 




