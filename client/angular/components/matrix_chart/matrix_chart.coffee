angular.module('loomioApp').directive 'matrixChart', (AppConfig) ->
  template: '<div class="matrix-chart"></div>'
  replace: true
  scope:
    matrixCounts: '='
    size: '@'
  restrict: 'E'
  controller: ($scope, $element) ->
    draw = SVG($element[0]).size('100%', '100%')
    shapes = []

    drawPlaceholder = ->
      _.each _.times(5), (row) ->
        _.each _.times(5), (col) ->
          drawShape(row, col, $scope.size / 5, false)

    drawShape = (row, col, width, value) ->
      color = if value then AppConfig.pollColors.meeting[0] else '#ebebeb'
      shapes.push(draw.rect(width-1, width-1)
                      .fill(color)
                      .x(width * row)
                      .y(width * col))

    $scope.$watchCollection 'matrixCounts', ->
      _.each shapes, (shape) -> shape.remove()
      return drawPlaceholder() if _.isEmpty($scope.matrixCounts)
      width = $scope.size / _.max([$scope.matrixCounts.length, $scope.matrixCounts[0].length])

      _.each $scope.matrixCounts, (values, row) ->
        _.each values, (value, col) ->
          drawShape(row, col, width, value)
