# Stopwatch summmary
# Summarise stopwatch object.
# 
# This is VERY preliminary and I really need to think
# about what is important to display here.  Hopefully the
# code will give you some ideas of what you can extract out 
# of this format
# 
# @arguments object to summarise
# @keyword debugging 
summary.stopwatch <- function(x, ...) {
	print(x[order(x$time, decreasing=TRUE)[1:10], c("f","level","start", "end", "time")])
	print(subset(x, leaf==TRUE, select=c("f","level","start", "end", "time")))
	print(xtabs(time ~ level, x))
}

# Plot stopwatch
# Plot a stopwatch object
# 
# This will plot the call tree of the specified stop watch object.
# If you only want a small part, you will need to subset the object
# 
# @arguments object to plot
# @arguments other arguments required for generic
# @arguments minimum units of time for function to get a label
# @keyword hplot
#X plot(glm_ex)
#X plot(subset(glm_ex, level < 5))
plot.stopwatch <- function(x, ..., minlabel = 0.1, angle = 0) {
	plot(1,1, xlim=range(x$start, x$end), ylim=range(x$level)+c(-0.5, 0.5), type="n", ..., xlab="time", ylab="level")
	rect(x$start, x$level - 0.5, x$end, x$level +0.5, ...)
	labels <- subset(x, time > max(time) * minlabel)
	if (nrow(labels) > 0)
	  text(labels$start, labels$level, labels$f, pos=4, angle=30, ...)
}

ggplot.stopwatch <- function(data, ..., minlabel = 0.1, angle=0) {
  if (!require("ggplot2", quiet=TRUE)) stop("Please install ggplot2 to use this plotting method")
  
  ggplot(as.data.frame(data), aes(x = factor(level))) + 
  geom_bar(aes(min = start, y = end, fill = source), position="identity", stat = "identity", width = 1) +
  geom_text(aes(label=f, y=start), hjust=0, data=subset(data, time > max(time) * minlabel), size=5, angle=angle) +
  scale_y_continuous("time") + scale_x_discrete("level") + 
  coord_flip()
}