angular.module('loomioApp').directive 'barChart', (AppConfig) ->
  template: '<div class="bar-chart"></div>'
  replace: true
  scope:
    stanceData: '='
    width: '@'
  restrict: 'E'
  controller: ($scope, $element) ->
    draw = SVG($element[0]).size('100%', '100%')
    shapes = []


    votedStances = ->
      _.select _.pairs($scope.stanceData), ([_, score]) -> score

    scoreData = ->
      _.map votedStances(), ([_, score], index) ->
        { color: AppConfig.pollColors[index], index: index, score: score }

    scoreMaxValue = ->
      _.max _.map(scoreData(), (data) -> data.score)

    $scope.$watchCollection 'stanceData', ->
      barHeight = $scope.width / votedStances().length
      _.each shapes, (shape) -> shape.remove()

      _.map scoreData(), (scoreData) ->
        barWidth = _.max [($scope.width * scoreData.score) / scoreMaxValue(), 1]
        draw.rect(barWidth, barHeight-2)
            .fill(scoreData.color)
            .x(0)
            .y(scoreData.index * barHeight)
