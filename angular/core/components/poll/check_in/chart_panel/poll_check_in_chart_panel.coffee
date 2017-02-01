angular.module('loomioApp').directive 'pollCheckInChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/check_in/chart_panel/poll_check_in_chart_panel.html'
  controller: ($scope) ->
    $scope.percentComplete = ->
      "#{100 * $scope.poll.stancesCount / $scope.poll.goal()}%"

    $scope.completeColor = $scope.poll.firstOption().color
