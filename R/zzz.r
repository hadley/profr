.onLoad <- function(libname, pkgname) {
  op <- options()
  op.profr <- list(
    profr.path = tempfile()
  )
  toset <- !(names(op.profr) %in% names(op))
  if(any(toset)) options(op.profr[toset])
}

