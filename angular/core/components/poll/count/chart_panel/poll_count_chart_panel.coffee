angular.module('loomioApp').directive 'pollCountChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/count/chart_panel/poll_count_chart_panel.html'
  controller: ($scope) ->
    $scope.percentComplete = ->
      "#{100 * $scope.poll.stanceCounts[0] / $scope.poll.goal()}%"

    $scope.completeColor = $scope.poll.firstOption().color
