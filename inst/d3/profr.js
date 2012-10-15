// Generated by CoffeeScript 1.3.3
(function() {
  var click, data, id, line_height, margin, mouse_out, mouse_over, redraw, rescale, shown, subset, svg, width, x_scale, y_scale;

  margin = {
    top: 10,
    right: 10,
    bottom: 10,
    left: 10
  };

  line_height = 20;

  svg = d3.select("body").selectAll(".chart").data([1]);

  svg.enter().append("svg");

  data = null;

  shown = null;

  x_scale = null;

  y_scale = null;

  subset = {
    x_min: 0,
    x_max: Infinity,
    y_min: 1
  };

  width = function(d) {
    return x_scale(d.end) - x_scale(d.start);
  };

  id = function(d) {
    return [d.start, d.level];
  };

  rescale = function() {
    var el, height, lines, win_height, win_width;
    win_width = window.innerWidth - margin.left - margin.right;
    win_height = window.innerHeight - margin.top - margin.bottom;
    lines = win_height / line_height << 0;
    height = lines * line_height;
    svg.attr("width", win_width).attr("height", win_height);
    shown = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        el = data[_i];
        if ((el.level - subset.x_min) < lines && el.start >= subset.x_min && el.end <= subset.x_max && el.level >= subset.y_min) {
          _results.push(el);
        }
      }
      return _results;
    })();
    x_scale = d3.scale.linear().range([0, win_width]).domain([
      subset.x_min, d3.max(shown, function(d) {
        return d.end;
      })
    ]);
    return y_scale = d3.scale.linear().range([0, win_height]).domain([
      subset.y_min - 1, d3.max(shown, function(d) {
        return d.level;
      })
    ]);
  };

  mouse_over = function(rec) {
    var fun, funs, info, rect;
    info = d3.select(".infobox");
    info.style("display", "block");
    info.select(".name").text(rec.f);
    info.select(".time").text(rec.time);
    funs = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        fun = data[_i];
        if (fun.f === rec.f) {
          _results.push(fun);
        }
      }
      return _results;
    })();
    return rect = svg.selectAll("rect").data(funs, id).classed("selected", true);
  };

  mouse_out = function(rec) {
    var fun, funs, rect;
    d3.select(".infobox").style("display", "none");
    funs = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        fun = data[_i];
        if (fun.f === rec.f) {
          _results.push(fun);
        }
      }
      return _results;
    })();
    return rect = svg.selectAll("rect").data(funs, id).classed("selected", false);
  };

  click = function(rec) {
    subset.x_min = rec.start;
    subset.x_max = rec.end;
    subset.y_min = rec.level;
    redraw();
    return d3.event.stopPropagation();
  };

  svg.on("click", function() {
    subset.x_min = 0;
    subset.x_max = Infinity;
    subset.y_min = 1;
    return redraw();
  });

  redraw = function() {
    var rect, text;
    rescale();
    rect = svg.selectAll("rect").data(shown, id);
    rect.enter().append("rect").on("mouseover", function(d) {
      return mouse_over(d);
    }).on("mouseout", function(d) {
      return mouse_out(d);
    }).on("click", (function(d) {
      return click(d);
    }), false);
    rect.exit().remove();
    rect.transition().attr("x", function(d) {
      return x_scale(d.start);
    }).attr("y", function(d) {
      return y_scale(d.level);
    }).attr("height", function(d) {
      return y_scale(d.level + 1) - y_scale(d.level);
    }).attr("width", function(d) {
      return x_scale(d.end) - x_scale(d.start);
    });
    text = svg.selectAll("text").data(shown, id);
    text.enter().append("text").text(function(d) {
      return d.f;
    });
    text.exit().remove();
    text.transition().attr("x", function(d) {
      return x_scale(d.start) + 4;
    }).attr("y", function(d) {
      return y_scale(d.level + 0.75);
    });
    return text.style("display", "block").each(function(d) {
      return this.__width = this.getBBox().width;
    }).style("display", function(d) {
      var w;
      w = this.__width;
      if (w === 0) {
        return "none";
      }
      if (w + 8 < width(d)) {
        return "block";
      } else {
        return "none";
      }
    });
  };

  window.onresize = redraw;

  d3.json("p.json", function(d) {
    data = d;
    return redraw();
  });

}).call(this);
