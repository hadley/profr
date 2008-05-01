# Parse Rprof output
# Parses the output of \code{\link{Rprof}} into an alternative format described in \code{\link{profr}}.
# 
# This produces a flat data frame, which is somewhat easier to summarise
# and visualise.
# 
# @argument path to \code{\link{Rprof}} output
# @argument real-time interval between samples
# @keyword debugging
# @value \code{\link{data.frame}} of class \code{profr}
# @seealso \code{\link{profr}} for profiling and parsing
parse_rprof <- function(path, interval=0.02) {
  lines <- scan(path, what="character", sep="\n")
	clean.lines <- lines[-grep("sample\\.interval=",lines)]
	calls <- sapply(clean.lines, strsplit, split=" ", USE.NAMES = FALSE)
	calls <- sapply(calls, rev)
	calls <- sapply(calls, function(x) gsub("\"","", x))
	
	attr(calls, "interval") <- interval
	
	df <- .simplify_all(.compact(calls))
	
	times <- c("time", "start", "end")
	df[times] <- df[times] * interval
	
	df[c("f", "level", times, "leaf", "source")]
}

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

.simplify <- function(df) {
  # for each level, want to collapse consecutive of the same function to one
  # provided all previous calls are the same too
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
	class(res) <- c("profr", "data.frame")
	res
}

.leaves <- function(df, x) {
	lev <- subset(df, level == x)

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
	
	packaged <- grep("package", fs)
	names <- sapply(strsplit(fs[packaged], ":"), "[", 2)
  
	fs[-packaged] <- NA
	fs[packaged] <- names
	unname(fs[as.character(df$f)])
}