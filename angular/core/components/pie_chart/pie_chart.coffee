angular.module('loomioApp').directive 'pieChart', (AppConfig) ->
  template: '<div class="pie-chart"></div>'
  replace: true
  scope:
    votes: '='
    diameter: '@'
  restrict: 'E'
  controller: ($scope, $element) ->
    draw = SVG($element[0]).size('100%', '100%')
    half = $scope.diameter / 2.0
    radius = half
    shapes = []

    arcPath = (startAngle, endAngle) ->
      rad = Math.PI / 180
      x1 = half + radius * Math.cos(-startAngle * rad)
      x2 = half + radius * Math.cos(-endAngle * rad)
      y1 = half + radius * Math.sin(-startAngle * rad)
      y2 = half + radius * Math.sin(-endAngle * rad)
      ["M", half, half, "L", x1, y1, "A", radius, radius, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"].join(' ')

    uniquePositionsCount = ->
      _.sum $scope.votes, (num) -> +(num > 0)

    sortedPositions = ->
      _.sortBy(_.pairs($scope.votes), ([_, count]) -> - count)

    colors =
      agree:    "#00D177"
      yes:      "#00D177"
      abstain:  "#F6A82B"
      disagree: "#F96268"
      no:       "#F96168"
      block:    "#CE261B"

    $scope.$watchCollection 'votes', ->
      _.each shapes, (shape) -> shape.remove()
      start = 90

      switch uniquePositionsCount()
        when 0
          shapes.push draw.circle($scope.diameter).attr
            'stroke-width': 0
            fill: '#aaa'
        when 1
          position = sortedPositions()[0][0]
          shapes.push draw.circle($scope.diameter).attr
            'stroke-width': 0
            fill: colors[position]
        else
          _.each sortedPositions(), ([position, votes]) ->
            return unless votes > 0
            angle = 360/_.sum($scope.votes)*votes
            shapes.push draw.path(arcPath(start, start + angle)).attr
              'stroke-width': 0
              fill: colors[position]
            start += angle
