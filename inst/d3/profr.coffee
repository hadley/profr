# TODO:
#
#  * use g for better semantic grouping
#  * better transitions from http://mbostock.github.com/d3/talk/20111018/partition.html
#  * approximation for text width
#  * translate/scale entire viewport instead of individuals?

margin = {top: 10, right: 10, bottom: 10, left: 10}
line_height = 25

svg = d3.select("body").selectAll(".chart").data([1])
svg.enter().append("svg")

data = null
shown = null
x_scale = null
y_scale = null

subset = 
  x_min: 0
  x_max: Infinity
  y_min: 1

width = (d) -> 
  left = Math.max(0, x_scale(d.end))
  right = Math.min(x_scale(d.start), subset.x_max)
  left - right
id = (d) -> [d.start, d.level]

# Ensure svg fills entire window (with round number of lines),
# subset data and set up scales
rescale = -> 
  win_width = window.innerWidth - margin.left - margin.right
  win_height = window.innerHeight - margin.top - margin.bottom

  lines = win_height / line_height << 0 # round down
  height = lines * line_height
  
  svg
    .attr("width", win_width)
    .attr("height", win_height)

  if (subset.x_max == Infinity) 
    subset.x_max = d3.max(data, (d) -> d.end)

  x_scale = d3.scale.linear()
    .rangeRound([0, win_width])
    .domain([subset.x_min, subset.x_max])
  y_scale = d3.scale.linear()
    .rangeRound([0, win_height])
    .domain([subset.y_min - 1, lines + subset.y_min])
    # -1 so there's enough room for the info bar

mouse_over = (rec) ->
  info = d3.select(".infobox")
  info.style("display", "block")
  info.select(".name").text(rec.f)
  info.select(".time").text(rec.time)

  funs = (fun for fun in data when fun.f == rec.f)
  rect = svg.selectAll("rect").data(funs, id)
    .classed("selected", true)

mouse_out = (rec) ->
  d3.select(".infobox").style("display", "none")

  funs = (fun for fun in data when fun.f == rec.f)
  rect = svg.selectAll("rect").data(funs, id)
    .classed("selected", false)


click = (rec) ->
  subset.x_min = rec.start
  subset.x_max = rec.end
  subset.y_min = rec.level

  redraw()
  d3.event.stopPropagation()

svg.on("click", -> 
  click {start: 0, end: Infinity, level: 1}
)

redraw = ->
  rescale()

  # Draw box for each function
  g = svg.selectAll("g").data(data, id).enter()
    .append("g")

  svg.selectAll("g").data(data, id)
    .transition(750)
    .attr("transform", (d) -> 
      "translate(" + x_scale(d.start) + "," + y_scale(d.level) + ")")

  g.append("rect")
    .on("mouseover", (d) -> mouse_over(d))
    .on("mouseout", (d) -> mouse_out(d))
    .on("click", ((d) -> click(d)), false)
    .attr("height", (d) -> line_height + "px")
 
  svg.selectAll("rect").data(data, id)
    .transition(750)
    .attr("width", width)
 
  # rect.exit().remove()

  # rect
  #   .transition()

  # Label functions, if space
  # text = svg.selectAll("text").data(shown, id)

  text = g.append("text")
    .text((d) -> d.f)
    .attr("y", "18px")
    .attr("x", "5px")

  # text.exit().remove()

  # text.transition()

  text
    .each((d) -> this.__width = this.getBBox().width)
    .style("opacity", (d) ->
      w = this.__width 
      return "none" if (w == 0)
      if w + 8 < width(d) then 1 else 0
    )

window.onresize = redraw
d3.json window.profr_path, (d) -> 
  data = d
  redraw()
