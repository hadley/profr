# Code to generate sample Rprof files

a <- function() runif(1e7)
b <- function() {
  rnorm(1e7)
  a()
}
c <- function() {
  a()
  b()
  a()
  return()
}

Rprof("nesting.rprof")
c()
Rprof(NULL)


data(diamonds, package="ggplot2")
library(reshape)

Rprof("diamonds.rprof")
dm <- melt(diamonds)
cast(dm, cut + color + clarity ~ variable, mean)
Rprof(NULL)
