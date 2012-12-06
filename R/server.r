#' Start server for profr d3 visualisation.
#'
#' This isn't absolutely necessary, but if you run the html from a
#' \code{file://} you can't request other local files. This server also
#' provides some convenience features like:
#'
#' \itemize{
#'  \item If the file doesn't exist in the base directory, we'll look in
#'    the installed package directory. That way you don't need to worry
#'    about having \code{d3.js} etc installed.
#'
#'  \item If a html file doesn't exist, a template will be rendered that
#'    runs the r2d3 js using a json file of the matching name.
#'
#'  \item \code{_json/objname} attempts to convert the object called
#'    \code{objname} into json.
#' }
#' @param base A directory specifying the base path where files are looked
#'   for.
#' @param appname The name of the application - this is only needed if you
#'   want to server multiple r2d3 servers out of different directories.
#' @param browse if \code{TRUE} will open the server in the browser if
#'   this is the first time that the server is instantiated.
#' @return (invisibly) the Rook server.
#' @import Rook
#' @keywords internal
#' @examples
#' start_server(system.file("examples", package = ""))
profr_server <- function(base = getOption("profr.path"), appname = "profr") {
  if (!is.null(server)) invisible(server)

  if (!file.exists(base)) {
    dir.create(base)
  }
  base <- normalizePath(base)

  server <- Rhttpd$new()
  server$add(make_router(base), appname)

  port <- tools:::httpdPort
  server_on <- port != 0
  if (!server_on) {
    server$start(quiet = TRUE)
  }

  server <<- server
  invisible(server)
}

server <- NULL

show_file <- function(path) {
  browseURL(paste0("http://localhost:", tools:::httpdPort, "/custom/profr/",
    path))
}

make_router <- function(base) {
  function(env) {
    req <- Request$new(env)
    path <- req$path_info()

    # Found in base directory, so serve it from there
    base_path <- file.path(base, path)
    if (file.exists(base_path)) {
      if (file.info(base_path)$isdir) {
        if (grepl("/$", path)) {
          # It's a directory, so make a basic index
          return(serve_index(base_path))
        } else {
          return(redirect(paste0(req$path(), "/")))
        }
      } else {
        return(serve_file(base_path))
      }
    }

    # Found in installed path, so serve it from there
    installed_path <- file.path(inst_path(), path)
    if (file.exists(installed_path)) return(serve_file(installed_path))

    # If it's an html file, and a json file with the same name exists,
    # serve the standard template
    json_path <- change_ext(path, "json")
    if (file.exists(file.path(base, json_path))) {
      return(serve_scaffold(paste0(req$script_name(), json_path)))
    }

    # Couldn't find it, so return 404.
    res <- Response$new(status = 404L)
    res$header("Content-type", "text/plain")
    res$write(paste("Couldn't find path:", path))
    res$finish()
  }
}

#' @importFrom tools file_ext
serve_file <- function(path) {
  stopifnot(file.exists(path))

  fi <- file.info(path)
  body <- readBin(path, 'raw', fi$size)

  res <- Response$new()
  res$header("Content-Type", Mime$mime_type(paste0(".", file_ext(path))))
  res$header("Content-Length", fi$size)
  res$body <- body
  res$finish()
}

#' @importFrom whisker whisker.render
serve_template <- function(template_path, data) {
  template <- readLines(file.path(inst_path(), template_path))
  body <- whisker.render(template, data)

  res <- Response$new()
  res$header("Content-Type", "text/html")
  res$write(body)
  res$finish()
}

serve_scaffold <- function(path) {
  serve_template("profr.html", list(json_path = path))
}

serve_index <- function(path) {
  files <- basename(dir(path))
  json <- files[file_ext(files) == "json"]
  files <- sort(c(files, change_ext(json, "html")))

  serve_template("index.html", list(files = files))
}

serve_object <- function(name) {
  if (!exists(name, globalenv())) {
    res <- Response$new(status = 404L)
    res$header("Content-type", "text/plain")
    res$write(paste("Couldn't find object", name))
    return(res$finish())
  }

  body <- json(get(name, globalenv()))

  res <- Response$new()
  res$header("Content-Type", "application/json")
  res$write(body)
  res$finish()
}

redirect <- function(path) {
  res <- Response$new(status = 301L)
  res$header("Location", path)
  res$finish()
}

#' @importFrom tools file_path_sans_ext
change_ext <- function(x, new_ext) {
  paste0(file_path_sans_ext(x), ".", new_ext)
}

inst_path <- function() {
  ns <- asNamespace("profr")

  if (is.null(ns$.__DEVTOOLS__)) {
    # staticdocs is probably installed
    system.file("d3", package = "profr")
  } else {
    # staticdocs was probably loaded with devtools
    file.path(getNamespaceInfo("profr", "path"), "inst", "d3")
  }
}
