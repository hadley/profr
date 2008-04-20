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


# New data structure experimentation
# =====================================

.compact <- function(s, order=TRUE,reverse=FALSE) {
	.compact.row <- function(s1) data.frame(f=s1$call, level=1:s1$depth, start=s1$start, leaf=1:s1$depth == s1$depth)

	depth <- sapply(s, length)
	s <- data.frame(
		call = array(unclass(s)),
		start = 0:(length(s)-1),
		depth = depth
	)
	
	structure(
		do.call(rbind, apply(s, 1, .compact.row)),
		interval = attr(s,"interval")
	)
}

# for each level, want to consecutive of the same function to one
# provided all previous calls are the same too
.simplify <- function(df) {
	change <- c(TRUE, (diff(df$start) == 1) & (df$f[-1] != df$f[-nrow(df)]))
	last_time <- max(df$start) + 1
	
	df <- df[change, ]
	df$time <- diff(c(df$start, last_time))
	df$end <- df$start + df$time

	df
}

.simplify_all <- function(df) {
	res <- do.call(rbind, 
		lapply(unique(df$level[df$level > 2] - 2), function(x) .simplify(subset(df, level==x)))
	)
	rownames(res) <- 1:nrow(res)
	res$leaf <- .leaves_all(res)
	res$source <- .function_sources(res)
	class(res) <- c("stopwatch", "data.frame")
	res
}

.leaves <- function(df, x) {
	lev <- subset(df, level==x)

	!sapply(1:nrow(lev), function(row)  {
		nrow(.relations(df, lev[row, "start"], lev[row, "end"], x+1)) > 0
	})
}
.leaves_all <- function(df) {
	unlist(lapply(1:max(df$level), function(x) .leaves(df, x)))
}
.relations <- function(df, start, end, levels) {
	df[df$level %in% levels & df$start >= start & df$end <= end, ]
}

.function_sources <- function(df) {
	fs <- sapply(levels(df$f), function(x) do.call(getAnywhere, list(x))$where[1])
	fs[as.character(df$f)]
}

# Stopwatch summmary
# Summarise stopwatch object.
# 
# This is VERY preliminary and I really need to think
# about what is important to display here.  Hopefully the
# code will give you some ideas of what you can extract out 
# of this format
# 
# @arguments object to summarise
# @keyword debugging 
summary.stopwatch <- function(x, ...) {
	print(x[order(x$time, decreasing=TRUE)[1:10], c("f","level","start", "end", "time")])
	print(subset(x, leaf==TRUE, select=c("f","level","start", "end", "time")))
	print(xtabs(time ~ level, x))
}

# Plot stopwatch
# Plot a stopwatch object
# 
# This will plot the call tree of the specified stop watch object.
# If you only want a small part, you will need to subset the object
# 
# @arguments object to plot
# @arguments other arguments required for generic
# @arguments minimum units of time for function to get a label
# @keyword hplot
#X plot(glm_ex)
#X plot(subset(glm_ex, level < 5))
plot.stopwatch <- function(x, ..., minlabel = 10) {
	plot(1,1, xlim=range(x$start, x$end), ylim=range(x$level)+c(-0.5, 0.5), type="n", ..., xlab="time", ylab="level")
	rect(x$start, x$level - 0.5, x$end, x$level +0.5, ...)
	labels <- subset(x, end - start > minlabel)
	text(labels$start, labels$level, labels$f, pos=4, srt=30, ...)
}