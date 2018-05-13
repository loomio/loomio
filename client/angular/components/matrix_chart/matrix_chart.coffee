
svg = require 'svg.js'

AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').directive 'matrixChart', ->
  template: '<div class="matrix-chart"></div>'
  replace: true
  scope:
    matrixCounts: '='
    size: '@'
  restrict: 'E'
  controller: ['$scope', '$element', ($scope, $element) ->
    draw = svg($element[0]).size('100%', '100%')
    shapes = []

    drawPlaceholder = ->
      _.each _.times(5), (row) ->
        _.each _.times(5), (col) ->
          drawShape(row, col, $scope.size / 5, 0)

    drawShape = (row, col, width, value) ->

      color = ['#ebebeb','#f3b300','#00e572'][value]

      shapes.push(draw.circle(width-1)
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
  ]
