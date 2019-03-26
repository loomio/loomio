
svg = require 'svg.js'

AppConfig      = require 'shared/services/app_config'

angular.module('loomioApp').directive 'progressChart', ->
  template: '<div class="progress-chart"></div>'
  replace: true
  scope:
    stanceCounts: '='
    goal: '='
    size: '@'
  restrict: 'E'
  controller: ['$scope', '$element', ($scope, $element) ->
    draw = svg($element[0]).size('100%', '100%')

    $scope.$watchCollection 'stanceCounts', ->
      y = 0
      _.each $scope.stanceCounts, (count, index) ->
        height = ($scope.size * _.max([parseInt(count), 0])) / $scope.goal
        draw.rect($scope.size, height)
            .fill(AppConfig.pollColors.count[index])
            .x(0)
            .y($scope.size - height - y)
        y += height

      draw.circle($scope.size / 2)
          .fill("#fff")
          .x($scope.size / 4)
          .y($scope.size / 4)

      draw.text((_.sum($scope.stanceCounts) || 0).toString())
          .font(size: 16, anchor: 'middle')
          .x($scope.size / 2)
          .y(($scope.size / 4) + 3)
  ]
