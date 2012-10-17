#' A generic method for displaying an object using d3.
#'
#' @export
#' @param x object to display
#' @param ... other arguments passed on to methods
d3 <- function(x, ...) UseMethod("d3")

#' Display a profr object with d3.
#'
#' @method d3 profr
#' @export
#' @importFrom digest digest
#' @examples
#' d3(nesting_prof)
d3.profr <- function(x, name = NULL, path = getOption("profr.path"), ...) {
  profr_server()

  if (is.null(name)) {
    name <- paste0(substr(digest(x), 1, 20), ".json")
  }

  writeLines(json(x), file.path(path, name))
  show_file(change_ext(name, "html"))
}

#' @importFrom rjson toJSON
json <- function(x) {
  n <- nrow(x)
  toJSON(lapply(seq_len(n), function(i) x[i, ]))
}
