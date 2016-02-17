angular.module('loomioApp').directive 'pieChart', ->
  template: '<div class="pie-chart"></div>'
  replace: true
  scope:
    votes: '='
  restrict: 'E'
  controller: ($scope, $element, $timeout) ->
    $timeout ->
      size = $element[0].offsetWidth
      draw = SVG($element[0]).size('100%', '100%')
      half = size / 2.0
      radius = half

      # setting canvas scaling on element resize
      #draw.setViewBox(0, 0, size, size, true );
      #draw.canvas.setAttribute('preserveAspectRatio', 'none');

      arcPath = (startAngle, endAngle) ->
        rad = Math.PI / 180
        x1 = half + radius * Math.cos(-startAngle * rad)
        x2 = half + radius * Math.cos(-endAngle * rad)
        y1 = half + radius * Math.sin(-startAngle * rad)
        y2 = half + radius * Math.sin(-endAngle * rad)
        ["M", half, half, "L", x1, y1, "A", radius, radius, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"].join(' ')

      positionColors =
        yes: '#39A96F'
        abstain: '#FAA030'
        no: '#F15E72'
        block: '#CE261B'

      shapes = []

      countUniquePositions = (votes) ->
        _.sum votes, (num) -> +(num > 0)

      $scope.$watch 'votes', ->
        # reset start angle and remove existing shapes
        start = 90
        _.each shapes, (arc) -> arc.remove()

        totalVotes = _.sum($scope.votes)
        voteAngle = 360/totalVotes
        totalSegments = countUniquePositions($scope.votes)
        sortedPositions = _.sortBy(_.pairs($scope.votes), (pair) -> - pair[1])

        switch totalSegments
          when 0
            shapes.push draw.circle(size).attr
              'stroke-width': 0
              fill: '#aaa'
          when 1
            position = sortedPositions[0][0]
            shapes.push draw.circle(size).attr
              'stroke-width': 0
              fill: positionColors[position]
          else
            _.each sortedPositions, (pair) ->
              position = pair[0]
              votes = pair[1]
              return if votes == 0
              angle = 360/totalVotes*votes
              shapes.push draw.path(arcPath(start, start + angle)).attr
                'stroke-width': 0
                fill: positionColors[position]
              start += angle
