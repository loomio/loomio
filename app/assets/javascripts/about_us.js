;(function() {

    var width = 960,
        height = 500,
        radius = Math.min(width, height) / 2;

    var color = d3.scale.category20();

    var pie = d3.layout.pie()
        .value(function(d) { return d.count; })
        .sort(null);

    var arc = d3.svg.arc()
        .innerRadius(radius - 100)
        .outerRadius(radius - 20);

    var svg = d3.select("pieContainer").append("svg")
        .attr("width", width)
        .attr("height", height)
      .append("g")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    var path = svg.selectAll("path");

    var draw = function(data) {
      console.log(data)
      var racesByGender = d3.nest()
          .key(function(d) { return d.gender;})
          .entries(data)
          .reverse();
          console.log(racesByGender)

      var label = d3.select("form").selectAll("label")
          .data(racesByGender)
        .enter().append("label");

      label.append("input")
          .attr("type", "radio")
          .attr("name", "gender")
          .attr("value", function(d) { return d.key; })
          .on("change", change)
        .filter(function(d, i) { return !i; })
          .each(change)
          .property("checked", true);

      label.append("span")
          .text(function(d) { return d.key; });

      function change(race) {
        var data0 = path.data(),
            data1 = pie(race.values);

        path = path.data(data1, key);

        path.enter().append("path")
            .each(function(d, i) { this._current = findNeighborArc(i, data0, data1, key) || d; })
            .attr("fill", function(d) { return color(d.data.race); })
          .append("title")
            .text(function(d) { return d.data.race; });

        path.exit()
            .datum(function(d, i) { return findNeighborArc(i, data1, data0, key) || d; })
          .transition()
            .duration(750)
            .attrTween("d", arcTween)
            .remove();

        path.transition()
            .duration(750)
            .attrTween("d", arcTween);
        }
    }


    function key(d) {
      return d.data.race;
    }

    function type(d) {
      d.count = +d.count;
      return d;
    }

    function findNeighborArc(i, data0, data1, key) {
      var d;
      return (d = findPreceding(i, data0, data1, key)) ? {startAngle: d.endAngle, endAngle: d.endAngle}
          : (d = findFollowing(i, data0, data1, key)) ? {startAngle: d.startAngle, endAngle: d.startAngle}
          : null;
    }

    // Find the element in data0 that joins the highest preceding element in data1.
    function findPreceding(i, data0, data1, key) {
      var m = data0.length;
      while (--i >= 0) {
        var k = key(data1[i]);
        for (var j = 0; j < m; ++j) {
          if (key(data0[j]) === k) return data0[j];
        }
      }
    }

    // Find the element in data0 that joins the lowest following element in data1.
    function findFollowing(i, data0, data1, key) {
      var n = data1.length, m = data0.length;
      while (++i < n) {
        var k = key(data1[i]);
        for (var j = 0; j < m; ++j) {
          if (key(data0[j]) === k) return data0[j];
        }
      }
    }

    function arcTween(d) {
      var i = d3.interpolate(this._current, d);
      this._current = i(0);
      return function(t) { return arc(i(t)); };
    }
    $.ajax({
       type: "GET",
       contentType: "application/json; charset=utf-8",
       url: 'user_data',
       dataType: 'json',
       success: function (data) {
          draw(data);
       },
       error: function (result) {
           error();
       }
    });
  })();