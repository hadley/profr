#' @examples
#' reshape_ex <- system.file("samples", "reshape.rprof", package="profr")
#' if (require("qtbase")) {
#'    explore(parse_rprof(reshape_ex)
#' }
explore <- function(df) {
  require("qtbase")
  require("qtpaint")
  
  ymax <- max(df$level) + 1
  xmax <- max(df$end)
  
  # dynamic variables
  highlights <- df[0, ]
  fun <- character()

  # painter functions
  rects_draw <- function(layer, painter, exposed) {
    qdrawRect(painter, xleft = highlights$start, xright = highlights$end, 
      ybottom = highlights$level - 1, ytop = highlights$level, 
      stroke = NA, fill = "grey80")
    
    qdrawRect(painter, xleft = df$start, xright = df$end, 
      ybottom = df$level - 1, ytop = df$level, stroke = "black", fill = NA)
    
    width <- qstrWidth(painter, df$f)
    labels <- df[df$time > width, ]
    qdrawText(painter, as.character(labels$f), x = labels$start, 
      y = labels$level - 0.5, halign = "left")

  }
  
  legend_draw <- function(layer, painter, exposed){
    text <- paste("call = ", fun, "()", sep = "") 
    if (length(fun) > 0) {
      qdrawText(painter, fun, x = 1, y = 5, halign = "left")      
    }
  }

  # event handlers
  rects_hover <- function(layer, event, ...) {
    fun <<- findFun(event)
    if (length(fun) > 1) stop("multiple matches")
    
    highlights <<- df[df$f == fun,]
    
    qupdate(rects)
    qupdate(legend)
  }  
  
  rects_press <- function(layer, event, ...) {
    fun_info <- zoomFun(event)
    if (nrow(fun_info) == 0) {
      rects$setLimits(qrect(0, 0, xmax, ymax))
    } else {
    rects$setLimits(qrect(x0 = fun_info$start, y0 = fun_info$level - 1,
      x1 = fun_info$end, y1 = ymax))
    }  
    qupdate(scene)
  }  
  
  # helpers 
  # finds function mouse is above
  findFun <- function(event){  
    x <- event$pos()$x()
    y <- event$pos()$y()
    level <- ceiling(y)
    
    possible.x <- df[df$start < x & df$end >= x, ]
    as.character(possible.x[possible.x$level == level, ]$f)
  }
  
  # extracts info about function clicked
  zoomFun <- function(event) {
    x <- event$pos()$x()
    y <- event$pos()$y()
    level <- ceiling(y)
    
    possible.x <- df[df$start < x & df$end >= x, ]
    row <- rownames(possible.x[possible.x$level == level, ])
    
    df[rownames(df) == row, ]
  }

  # building plot
  scene <- qscene()
  root <- qlayer(scene, cache = TRUE) #note: root necessary to avoid bug
  legend <- qlayer(root, legend_draw)
  rects <- qlayer(root, rects_draw, row = 1, 
    hoverMoveFun = rects_hover,
    mousePressFun = rects_press)
  
  # set layer limits
  legend$setLimits(qrect(0, 0, 100, 10))
  rects$setLimits(qrect(0, 0, xmax, ymax))

  #set layout
  layout <- root$gridLayout()
  layout$setRowMaximumHeight(0,20)
  layout$setRowMinimumHeight(0,20)  
  layout$setRowMinimumHeight(1,100)


  view <- qplotView(scene = scene)
  view
}
