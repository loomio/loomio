AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'

module.exports =
  props:
  data: ->
  methods:
  template:
    """
    .poll-count-chart-panel
      %h3.lmo-card-subheading{translate: "poll_common.results"}
      .poll-count-chart-panel__chart-container
        .poll-count-chart-panel__progress
          .poll-count-chart-panel__incomplete
          .poll-count-chart-panel__no{ng-style: "{'flex-basis': percentComplete(1), 'background-color': colors[1]}"}
          .poll-count-chart-panel__yes{ng-style: "{'flex-basis': percentComplete(0), 'background-color': colors[0]}"}
        .poll-count-chart-panel__data
          .poll-count-chart-panel__numerator {{poll.stancesCount}}
          .poll-count-chart-panel__denominator{translate: "poll_count_chart_panel.out_of", translate-value-goal: "{{poll.goal()}}"}
    """

angular.module('loomioApp').directive 'pollCountChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_count_chart_panel.haml')
  controller: ['$scope', ($scope) ->
    $scope.percentComplete = (index) ->
      "#{100 * $scope.poll.stanceCounts[index] / $scope.poll.goal()}%"

    $scope.colors = AppConfig.pollColors.count
  ]
