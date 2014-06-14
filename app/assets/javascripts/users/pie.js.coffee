# $().ready () ->
#   d3.select('svg').append('p')

pieCharts = [
  {
    svg      : 'svg#gender',
    json     : 'users/gender',
    category : (d) -> d.data.gender,
    text     : (d) -> d.data.gender,
    # text     : (d) -> "#{d.data.gender}(#{d.data.population}人)",
  },
  {
    svg      : 'svg#age',
    json     : 'users/age',
    category : (d) -> d.data.age,
    text     : (d) -> d.data.age
    # text     : (d) -> "#{d.data.age}(#{d.data.population}人)"
  }
]

width = $("div.col-md-6").width()
height = 400
radius = Math.min(width, height) / 2

arc = d3.svg
  .arc()
  .outerRadius(radius * 0.8)
  .innerRadius(0)

outerArc = (i) ->
  d3.svg.arc()
    .innerRadius(radius * i)
    .outerRadius(radius * i)

pieCharts.forEach (p) ->
  color = d3.scale.category10()

  pie = d3.layout
    .pie()
    .sort(null)
    .value( (d) -> d.population )

  svg = d3.select p['svg']
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(#{width / 2},#{height / 2})")

  d3.json(p['json'], (error, data) ->
    sum = d3.sum(data, (d) -> d.population)
    data.forEach( (d) -> d.population = +d.population )
    midAngle = (d) -> d.startAngle + (d.endAngle - d.startAngle)/2

    g = svg.selectAll(".arc")
      .data(pie(data))
      .enter()
      .append("g")
      .attr("class", "arc")

    g.append("path")
      .on('mouseover', () -> d3.select(this).attr('opacity', 0.7))
      .on('mouseout', () -> d3.select(this).attr('opacity', 1))
      .attr("d", arc)
      .attr("stroke", "white")
      .style("fill", (d) -> color p['category'](d) )
      .transition()
      .duration(1000)
      .attrTween("d", (d) ->
        interpolate = d3.interpolate(
          { startAngle : 0, endAngle : 0 },
          { startAngle : d.startAngle, endAngle : d.endAngle }
        )
        (t) -> arc interpolate(t)
      )

    g.append("text")
      .attr('transform', (d) ->
        pos = outerArc(0.9).centroid(d)
        midAngle = d.startAngle + (d.endAngle - d.startAngle)/2
        pos[0] = radius * 0.95 * (if midAngle < Math.PI then 1 else -1)
        return "translate(" + pos + ")"
      )
      .attr("dy", ".35em")
      .style('text-anchor', (d) ->
        midAngle = d.startAngle + (d.endAngle - d.startAngle)/2
        return if midAngle < Math.PI then "start" else "end"
      )
      .transition()
      .delay(1200)
      .text( (d) -> p['text'](d) )

    g.append("text")
      .attr("transform", (d) -> "translate(" + arc.centroid(d) + ")" )
      .attr("dy", ".35em")
      .style("text-anchor", "middle")
      .style('fill', 'white')
      .transition()
      .delay(1100)
      .text( (d) ->
        rate = Math.round(d.data.population / sum * 100)
        if rate > 5
          return rate + '%'
      )

    g.append('polyline')
      .attr({
        opacity        : .6,
        stroke         : 'black',
        'stroke-width' : 2,
        fill           : 'none'
      })
      .transition()
      .delay(1000)
      .duration(2000)
      .attr('points', (d) ->
        interpolate = d3.interpolate(
          { startAngle : 0, endAngle : 0 },
          { startAngle : d.startAngle, endAngle : d.endAngle }
        )
        pos = outerArc(0.9).centroid(d)
        midAngle = d.startAngle + (d.endAngle - d.startAngle)/2
        pos[0] = radius * 0.95 * (if midAngle < Math.PI then 1 else -1)
        return [outerArc(0.8).centroid(d), outerArc(0.9).centroid(d), pos]
      )
  )
