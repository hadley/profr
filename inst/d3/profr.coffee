margin = {top: 10, right: 10, bottom: 10, left: 10}
line_height = 20

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

width = (d) -> x_scale(d.end) - x_scale(d.start)
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

  shown = (el for el in data when (el.level - subset.x_min) < lines and el.start >= subset.x_min and 
    el.end <= subset.x_max and el.level >= subset.y_min)
  x_scale = d3.scale.linear()
    .range([0, win_width])
    .domain([subset.x_min, d3.max(shown, (d) -> d.end)])
  y_scale = d3.scale.linear()
    .range([0, win_height])
    .domain([subset.y_min - 1, d3.max(shown, (d) -> d.level)])
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
  subset.x_min = 0
  subset.x_max = Infinity
  subset.y_min = 1

  redraw()
)

redraw = ->
  rescale()

  # Draw box for each function
  rect = svg.selectAll("rect").data(shown, id)

  rect.enter().append("rect")
    .on("mouseover", (d) -> mouse_over(d))
    .on("mouseout", (d) -> mouse_out(d))
    .on("click", ((d) -> click(d)), false)
 
  rect.exit().remove()

  rect
    .transition()
    .attr("x", (d) -> x_scale(d.start))
    .attr("y", (d) -> y_scale(d.level))
    .attr("height", (d) -> y_scale(d.level + 1) - y_scale(d.level))
    .attr("width", (d) -> x_scale(d.end) - x_scale(d.start))

  # Label functions, if space
  text = svg.selectAll("text").data(shown, id)

  text.enter().append("text")
    .text((d) -> d.f)

  text.exit().remove()

  text.transition()
    .attr("x", (d) -> x_scale(d.start) + 4)
    .attr("y", (d) -> y_scale(d.level + 0.75))

  text
    .style("display", "block")
    .each((d) -> this.__width = this.getBBox().width)
    .style("display", (d) ->
      w = this.__width 
      return "none" if (w == 0)
      if w + 8 < width(d) then "block" else "none"
    )

window.onresize = redraw
d3.json window.profr_path, (d) -> 
  data = d
  redraw()
