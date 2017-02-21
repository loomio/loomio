angular.module('loomioApp').directive 'pollPollChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/poll/chart_panel/poll_poll_chart_panel.html'
  controller: ($scope) ->
    $scope.countFor = (option) ->
      $scope.poll.stanceData[option.name] or 0

    $scope.percentageFor = (option) ->
      max = _.max(_.values($scope.poll.stanceData))
      return unless max > 0
      "#{100 * $scope.countFor(option) / max}%"

    $scope.barTextFor = (option) ->
      "#{option.name} - #{$scope.countFor(option)}".replace(/\s/g, '\u00a0')
