#' Parse Rprof output.
#' Parses the output of \code{\link{Rprof}} into an alternative format
#' described in \code{\link{profr}}.
#' 
#' This produces a flat data frame, which is somewhat easier to summarise
#' and visualise.
#' 
#' @param path path to \code{\link{Rprof}} output
#' @param interval real-time interval between samples (in seconds)
#' @keywords debugging
#' @return \code{\link{data.frame}} of class \code{profr}
#' @seealso \code{\link{profr}} for profiling and parsing
#' @import stringr plyr
#' @export
#' @examples
#' nesting <- parse_rprof(system.file("samples", "nesting.rprof", package="profr"))
#' 
#' reshape_ex <- system.file("samples", "reshape.rprof", package="profr")
#' diamonds <- parse_rprof(reshape_ex)
#' p <- profr(parse_rprof(reshape_ex))
parse_rprof <- function(path, interval=0.02) {
  lines <- readLines(path)[-1]
  
  calls <- str_split(lines, " ")
  calls <- lapply(calls, function(x) rev(str_replace_all(x, "\"", ""))[-1])
  
  df <- .simplify(calls)
  
  times <- c("time", "start", "end")
  df[times] <- df[times] * interval
  
  df
}

.simplify <- function(calls) {
  df <- ldply(seq_along(calls), function(i) {
    call <- calls[[i]]
    call_info(call, i)
  })
  
  group_id <- function(x) {
    n <- length(x)
    cumsum(c(TRUE, x[-1] != x[-n]))
  } 
  levels <- ddply(df, "level", mutate, id = group_id(hist))
  
  collapsed <- ddply(levels, c("level", "id"), summarise, 
    f = f[1], 
    start = min(start), 
    end = max(end), 
    n = length(f),
    leaf = leaf[1]
  )
  collapsed <- mutate(collapsed,
    time = end - start,
    source = function_source(f)
  )
  # subset(collapsed, time != n)
  
  structure(collapsed, class = c("profr", "data.frame"))
}

call_info <- function(call, i) {
  n <- length(call)
  history <- unlist(lapply(seq_along(call), function(i) {
    digest(call[seq_len(i)])
  }))
  
  quickdf(list(
    f = call, 
    level = seq_along(call), 
    start = rep(i, n), 
    end = rep(i + 1, n),
    leaf = c(rep(FALSE, n - 1), TRUE),
    hist = history
  ))
}

function_source <- function(f) {
  pkgs <- search()
  names(pkgs) <- pkgs
  all_objs <- ldply(pkgs, as.data.frame(ls))
  names(all_objs) <- c("package", "f")
  all_objs$package <- str_replace_all(all_objs$package, "package:", "")

  all_objs$package[match(f, all_objs$f)]
}
