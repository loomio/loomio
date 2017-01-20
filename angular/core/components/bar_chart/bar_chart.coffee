angular.module('loomioApp').directive 'barChart', (AppConfig) ->
  template: '<div class="bar-chart"></div>'
  replace: true
  scope:
    stanceData: '='
    size: '@'
  restrict: 'E'
  controller: ($scope, $element) ->
    draw = SVG($element[0]).size('100%', '100%')
    shapes = []

    scoreData = ->
      _.take(_.map(_.pairs($scope.stanceData), ([_, score], index) ->
        { color: AppConfig.pollColors[index], index: index, score: score }), 5)

    scoreMaxValue = ->
      _.max _.map(scoreData(), (data) -> data.score)

    drawPlaceholder = ->
      barHeight = $scope.size / 3
      barWidths =
        0: $scope.size
        1: 2 * $scope.size / 3
        2: $scope.size / 3

      _.each barWidths, (width, index) ->
        draw.rect(width, barHeight - 2)
            .fill("#ebebeb")
            .x(0)
            .y(index * barHeight)

    $scope.$watchCollection 'stanceData', ->
      _.each shapes, (shape) -> shape.remove()
      return drawPlaceholder() unless scoreData().length > 0 and scoreMaxValue() > 0
      barHeight = $scope.size / scoreData().length

      _.map scoreData(), (scoreData) ->
        barWidth = _.max([($scope.size * scoreData.score) / scoreMaxValue(), 2])
        draw.rect(barWidth, barHeight-2)
            .fill(scoreData.color)
            .x(0)
            .y(scoreData.index * barHeight)
