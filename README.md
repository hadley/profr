# profr 

`profr` provides an alternative data structure and display for profiling data. It still uses `Rprof()` to collect the data, but outputs a data.frame which should be easier to manipulate. It also implements a novel visualisation which allows you to see the time taken by each function, as well as the context in which it was called.

To get started, try:

    install.packages("profr")
    library(profr)
    p <- profr(my.slow.function())
    plot(p)

Two built in examples are:

    plot(nesting_prof)
    plot(reshape_prof)

(and the second has helped me to considerably speed up (5-20x) the development version of reshape)
