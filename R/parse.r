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
#X nesting <- parse_rprof(system.file("samples", "nesting.rprof", package="profr"))
#X diamonds <- parse_rprof(system.file("samples", "reshape.rprof", package="profr"))
parse_rprof <- function(path, interval=0.02) {
  lines <- scan(path, what="character", sep="\n")
  
  clean.lines <- lines[-grep("sample\\.interval=",lines)]
  calls <- sapply(clean.lines, strsplit, split=" ", USE.NAMES = FALSE)
  calls <- sapply(calls, rev)
  calls <- sapply(calls, function(x) gsub("\"","", x))
  
  df <- .simplify(calls)
  
  times <- c("time", "start", "end")
  df[times] <- df[times] * interval
  
  df[c("f", "level", times, "leaf", "source")]
}

.simplify <- function(calls) {
  df <- .expand(calls)
  
  levels <- split(df, df$level)
  res <- do.call(rbind, lapply(levels, .collapse_adjacent))

  rownames(res) <- 1:nrow(res)
  res$time <- res$end - res$start
  res$source <- .function_sources(res)
  class(res) <- c("profr", "data.frame")
  res
}

.collapse_adjacent <- function(df) {
  # for each level, want to collapse consecutive of the same function to one
  # provided all previous calls are the same too
  
  id <- cumsum(c(TRUE, df$hist[-1] != df$hist[-nrow(df)]))
  groups <- lapply(split(df, id), function(df) {
    transform(df[1, ], end = max(df$end))
  })
  do.call("rbind", groups)
}

.expand <- function(calls) {
  .expand.call <- function(s1) with(s1, data.frame(
    f = call, 
    level = 1:depth, 
    start = start, 
    end = start + 1,
    leaf = 1:depth == depth,
    hist = sapply(1:depth, function(i) digest(call[seq_len(i)]))
  ))
  
  depth <- sapply(calls, length)
  calldf <- data.frame(
    call = array(unclass(calls)),
    start = 0:(length(calls)-1),
    depth = depth
  )
  
  do.call(rbind, apply(calldf, 1, .expand.call))
}


.function_sources <- function(df) {
  fs <- sapply(levels(df$f), function(x) do.call(getAnywhere, list(x))$where[1])
  
  packaged <- grep("package", fs)
  names <- sapply(strsplit(fs[packaged], ":"), "[", 2)
  
  fs[-packaged] <- NA
  fs[packaged] <- names
  unname(fs[as.character(df$f)])
}