angular.module('loomioApp').directive 'pollCheckInChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/check_in/chart_panel/poll_check_in_chart_panel.html'
  controller: ($scope) ->
    $scope.poll.customFields = { goal: 14 }

    $scope.percentComplete = ->
      "#{100 * $scope.poll.stancesCount / $scope.poll.customFields.goal}%"

    $scope.completeColor = _.first(AppConfig.pollColors)
