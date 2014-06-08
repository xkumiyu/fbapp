width = $("div.col-md-6").width()
height = 500
radius = Math.min(width, height) / 2

color = d3.scale
  .ordinal()
  .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"])

arc = d3.svg
  .arc()
  .outerRadius(radius - 10).innerRadius(0)

pie = d3.layout
  .pie()
  .sort(null)
  .value( (d) -> d.population )

svg = d3.select('svg#age')
  .attr("width", width)
  .attr("height", height)
  .append("g")
  .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

d3.json("users/age", (error, data) ->
  data.forEach( (d) -> d.population = +d.population )

  g = svg.selectAll(".arc")
    .data(pie(data))
    .enter()
    .append("g")
    .attr("class", "arc")

  g.append("path")
    .attr("d", arc)
    .style("fill", (d) -> color(d.data.age) )

  g.append("text")
    .attr("transform", (d) -> "translate(" + arc.centroid(d) + ")" )
    .attr("dy", ".35em")
    .style("text-anchor", "middle")
    .text( (d) -> d.data.age )
)
