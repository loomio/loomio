AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'

angular.module('loomioApp').directive 'pollCountChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_count_chart_panel.haml')
  controller: ['$scope', ($scope) ->
    $scope.percentComplete = (index) ->
      "#{100 * $scope.poll.stanceCounts[index] / $scope.poll.goal()}%"

    $scope.colors = AppConfig.pollColors.count
  ]
