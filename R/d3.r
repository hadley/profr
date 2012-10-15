#' @importFrom RJSONIO toJSON

json <- function(x) {
  n <- nrow(x)
  toJSON(lapply(seq_len(n), function(i) x[i, ]))
}

save_json <- function(x, path) {
  writeLines(json(x), path)
}
