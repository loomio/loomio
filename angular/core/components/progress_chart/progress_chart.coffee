angular.module('loomioApp').directive 'progressChart', (AppConfig) ->
  template: '<div class="progress-chart"></div>'
  replace: true
  scope:
    stanceCounts: '='
    goal: '='
    size: '@'
  restrict: 'E'
  controller: ($scope, $element) ->
    draw = SVG($element[0]).size('100%', '100%')

    count = ->
      parseInt($scope.stanceCounts[0]) || 0

    $scope.$watchCollection 'stanceCounts', ->
      progressHeight = ($scope.size * count()) / $scope.goal

      draw.rect($scope.size, progressHeight)
          .fill(AppConfig.pollColors.count[0])
          .x(0)
          .y($scope.size - progressHeight)

      draw.circle($scope.size / 2)
          .fill("#fff")
          .x($scope.size / 4)
          .y($scope.size / 4)

      draw.text(count().toString())
          .font(size: 16, anchor: 'middle')
          .x($scope.size / 2)
          .y(($scope.size / 4) + 3)
