AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'pollCountChartPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/count/chart_panel/poll_count_chart_panel.html'
  controller: ['$scope', ($scope) ->
    $scope.percentComplete = (index) ->
      "#{100 * $scope.poll.stanceCounts[index] / $scope.poll.goal()}%"

    $scope.colors = AppConfig.pollColors.count
  ]
