angular.module('loomioApp').directive 'pollCountChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/count/chart_panel/poll_count_chart_panel.html'
  controller: ($scope) ->
    $scope.percentComplete = (index) ->
      "#{100 * $scope.poll.stanceCounts[index] / $scope.poll.goal()}%"

    $scope.colors = AppConfig.pollColors.count
