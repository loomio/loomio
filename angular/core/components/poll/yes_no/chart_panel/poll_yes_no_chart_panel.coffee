angular.module('loomioApp').directive 'pollYesNoChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/yes_no/chart_panel/poll_yes_no_chart_panel.html'
  controller: ($scope) ->
    $scope.percentComplete = ->
      "#{100 * $scope.poll.stanceCounts[0] / $scope.poll.goal()}%"

    $scope.completeColor = $scope.poll.firstOption().color
