(function() {
  var arc, height, outerArc, pieCharts, radius, width;

  pieCharts = [
    {
      svg: 'svg#gender',
      json: 'users/gender',
      category: function(d) {
        return d.data.gender;
      },
      text: function(d) {
        return d.data.gender;
      }
    }, {
      svg: 'svg#age',
      json: 'users/age',
      category: function(d) {
        return d.data.age;
      },
      text: function(d) {
        return d.data.age;
      }
    }
  ];

  width = $("div.col-md-6").width();

  height = 400;

  radius = Math.min(width, height) / 2;

  arc = d3.svg.arc().outerRadius(radius * 0.8).innerRadius(0);

  outerArc = function(i) {
    return d3.svg.arc().innerRadius(radius * i).outerRadius(radius * i);
  };

  pieCharts.forEach(function(p) {
    var color, pie, svg;
    color = d3.scale.category10();
    pie = d3.layout.pie().sort(null).value(function(d) {
      return d.population;
    });
    svg = d3.select(p['svg']).attr("width", width).attr("height", height).append("g").attr("transform", "translate(" + (width / 2) + "," + (height / 2) + ")");
    return d3.json(p['json'], function(error, data) {
      var g, midAngle, sum;
      sum = d3.sum(data, function(d) {
        return d.population;
      });
      data.forEach(function(d) {
        return d.population = +d.population;
      });
      midAngle = function(d) {
        return d.startAngle + (d.endAngle - d.startAngle) / 2;
      };
      g = svg.selectAll(".arc").data(pie(data)).enter().append("g").attr("class", "arc");
      g.append("path").on('mouseover', function() {
        return d3.select(this).attr('opacity', 0.7);
      }).on('mouseout', function() {
        return d3.select(this).attr('opacity', 1);
      }).attr("d", arc).attr("stroke", "white").style("fill", function(d) {
        return color(p['category'](d));
      }).transition().duration(1000).attrTween("d", function(d) {
        var interpolate;
        interpolate = d3.interpolate({
          startAngle: 0,
          endAngle: 0
        }, {
          startAngle: d.startAngle,
          endAngle: d.endAngle
        });
        return function(t) {
          return arc(interpolate(t));
        };
      });
      g.append("text").attr('transform', function(d) {
        var pos;
        pos = outerArc(0.9).centroid(d);
        midAngle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        pos[0] = radius * 0.95 * (midAngle < Math.PI ? 1 : -1);
        return "translate(" + pos + ")";
      }).attr("dy", ".35em").style('text-anchor', function(d) {
        midAngle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        if (midAngle < Math.PI) {
          return "start";
        } else {
          return "end";
        }
      }).transition().delay(1200).text(function(d) {
        return p['text'](d);
      });
      g.append("text").attr("transform", function(d) {
        return "translate(" + arc.centroid(d) + ")";
      }).attr("dy", ".35em").style("text-anchor", "middle").style('fill', 'white').transition().delay(1100).text(function(d) {
        var rate;
        rate = Math.round(d.data.population / sum * 100);
        if (rate > 5) {
          return rate + '%';
        }
      });
      return g.append('polyline').attr({
        opacity: .6,
        stroke: 'black',
        'stroke-width': 2,
        fill: 'none'
      }).transition().delay(1000).duration(2000).attr('points', function(d) {
        var interpolate, pos;
        interpolate = d3.interpolate({
          startAngle: 0,
          endAngle: 0
        }, {
          startAngle: d.startAngle,
          endAngle: d.endAngle
        });
        pos = outerArc(0.9).centroid(d);
        midAngle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        pos[0] = radius * 0.95 * (midAngle < Math.PI ? 1 : -1);
        return [outerArc(0.8).centroid(d), outerArc(0.9).centroid(d), pos];
      });
    });
  });

}).call(this);
