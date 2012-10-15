# TODO:
#
# * on hover, highlight all use of current function
# * on click, zoom into that entry and its children

margin = {top: 10, right: 10, bottom: 10, left: 10}
line_height = 20

svg = d3.select("body").selectAll(".chart").data([1])
svg.enter().append("svg")

data = null
shown = null
x_scale = null
y_scale = null
width = (d) -> x_scale(d.end - d.start)
id = (d) -> [d.start, d.level]

# Ensure svg fills entire window (with round number of lines),
# subset data and set up scales
rescale = -> 
  width = window.innerWidth - margin.left - margin.right
  height = window.innerHeight - margin.top - margin.bottom

  lines = height / line_height << 0 # round down
  height = lines * line_height
  
  svg
    .attr("width", width)
    .attr("height", height)

  shown = (el for el in data when el.level < lines)
  x_scale = d3.scale.linear()
    .range([0, width])
    .domain([0, d3.max(shown, (d) -> d.end)])
  y_scale = d3.scale.linear()
    .range([0, height])
    .domain([0, d3.max(shown, (d) -> d.level)])


mouse_over = (rec) ->
  info = d3.select(".infobox")
  info.style("display", "block")
  info.select(".name").text(rec.f)
  info.select(".time").text(rec.time)

  funs = (fun for fun in data when fun.f == rec.f)
  rect = svg.selectAll("rect").data(funs, id).
    attr("fill", "red")

mouse_out = (rec) ->
  d3.select(".infobox").style("display", "none")

  funs = (fun for fun in data when fun.f == rec.f)
  rect = svg.selectAll("rect").data(funs, id).
    attr("fill", "white")
  

redraw = ->
  rescale()

  # Draw box for each function
  rect = svg.selectAll("rect").data(shown, id)

  rect.enter().append("rect")
    .attr("fill", "white")
    .attr("stroke", "black")
    .on("mouseover", (d) -> mouse_over(d))
    .on("mouseout", (d) -> mouse_out(d))

  rect
    .attr("x", (d) -> x_scale(d.start))
    .attr("y", (d) -> y_scale(d.level))
    .attr("height", (d) -> y_scale(1))
    .attr("width", (d) -> x_scale(d.end) - x_scale(d.start))

  # # Label functions, if space
  # text = svg.selectAll("text").data(shown, id)

  # text.enter().append("text")
  #   .text((d) -> d.f)

  # text
  #   .attr("x", (d) -> x_scale(d.start) + 4)
  #   .attr("y", (d) -> y_scale(d.level + 0.75))

  # text.style("display", (d, i) -> 
  #   if (this.getBBox().width + 8 < width(d)) then "block" else "none"
  # )

window.onresize = redraw
d3.json "p.json", (d) -> 
  data = d
  redraw()


