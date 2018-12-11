svg = require 'svg.js'

module.exports = Vue.component 'BarChart',
  props:
    stanceCounts: Array
    size: Number
  methods:
    scoreData: ->
      _.take(_.map(this.stanceCounts, (score, index) ->
        { color: AppConfig.pollColors.poll[index], index: index, score: score }), 5)
    scoreMaxValue: ->
      _.max _.map(scoreData(), (data) -> data.score)
    drawPlaceholder: ->
      barHeight = this.size / 3
      barWidths =
        0: this.size
        1: 2 * this.size / 3
        2: this.size / 3
      _.each barWidths, (width, index) ->
        draw.rect(width, barHeight - 2)
            .fill("#ebebeb")
            .x(0)
            .y(index * barHeight)
  template: '<div class="bar-chart"></div>'
#
# AppConfig = require 'shared/services/app_config'
#
# angular.module('loomioApp').directive 'barChart', ->
#   template: '<div class="bar-chart"></div>'
#   replace: true
#   scope:
#     stanceCounts: '='
#     size: '@'
#   restrict: 'E'
#   controller: ['$scope', '$element', ($scope, $element) ->
#     draw = svg($element[0]).size('100%', '100%')
#     shapes = []
#

#
#     $scope.$watchCollection 'stanceCounts', ->
#       _.each shapes, (shape) -> shape.remove()
#       return drawPlaceholder() unless scoreData().length > 0 and scoreMaxValue() > 0
#       barHeight = $scope.size / scoreData().length
#
#       _.map scoreData(), (scoreData) ->
#         barWidth = _.max([($scope.size * scoreData.score) / scoreMaxValue(), 2])
#         draw.rect(barWidth, barHeight-2)
#             .fill(scoreData.color)
#             .x(0)
#             .y(scoreData.index * barHeight)
#   ]
