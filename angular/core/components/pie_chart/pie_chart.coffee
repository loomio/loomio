angular.module('loomioApp').directive 'pieChart', ->
  templateUrl: 'generated/components/pie_chart/pie_chart.html'
  replace: true
  scope: {proposal: '='}
  restrict: 'E'
  controller: ($scope, $element) ->
    size = $element[0].offsetWidth
    draw = SVG($element[0]).size('100%', '100%')
    half = size / 2.0
    radius = half
    shapes = []

    positionColors =
      yes: '#00D177'
      abstain: '#F6A82B'
      no: '#F96168'
      block: '#CE261B'

    arcPath = (startAngle, endAngle) ->
      rad = Math.PI / 180
      x1 = half + radius * Math.cos(-startAngle * rad)
      x2 = half + radius * Math.cos(-endAngle * rad)
      y1 = half + radius * Math.sin(-startAngle * rad)
      y2 = half + radius * Math.sin(-endAngle * rad)
      ["M", half, half, "L", x1, y1, "A", radius, radius, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"].join(' ')

    uniquePositionsCount = ->
      _.sum $scope.proposal.voteCounts, (num) -> +(num > 0)

    sortedPositions = ->
      _.sortBy(_.pairs($scope.proposal.voteCounts), ([_, count]) -> - count)

    $scope.$watchCollection 'proposal.voteCounts', ->
      console.time('pieDraw')
      _.each shapes, (shape) -> shape.remove()
      start = 90

      switch uniquePositionsCount()
        when 0
          shapes.push draw.circle(size).attr
            'stroke-width': 0
            fill: '#aaa'
        when 1
          position = sortedPositions()[0][0]
          shapes.push draw.circle(size).attr
            'stroke-width': 0
            fill: positionColors[position]
        else
          _.each sortedPositions(), ([position, votes]) ->
            return unless votes > 0
            angle = 360/_.sum($scope.proposal.voteCounts)*votes
            shapes.push draw.path(arcPath(start, start + angle)).attr
              'stroke-width': 0
              fill: positionColors[position]
            start += angle
      console.timeEnd('pieDraw')
