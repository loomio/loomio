angular.module('loomioApp').directive 'pollCommonBarChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/bar_chart_panel/poll_common_bar_chart_panel.html'
  controller: ($scope) ->
    $scope.countFor = (option) ->
      $scope.poll.stanceData[option.name] or 0

    $scope.percentageFor = (option) ->
      max = _.max(_.values($scope.poll.stanceData))
      return unless max > 0
      "#{100 * $scope.countFor(option) / max}%"

    $scope.barTextFor = (option) ->
      "#{$scope.countFor(option)} - #{option.name}".replace(/\s/g, '\u00a0')

    $scope.backgroundImageFor = (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"
