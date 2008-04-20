
# Trim call tree to start with specified function
# 
# 
# @keyword internal
trim <- function(calltree, f) {
  trimmed <- compact(lapply(calltree, function(x) {
    if (!any(x == f)) return(NULL)
    tail(x, -(which(x == f)[1] - 1))
  }))
  attributes(trimmed) <- attributes(calltree)
  trimmed
}
