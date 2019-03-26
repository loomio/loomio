AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'

angular.module('loomioApp').directive 'pollCommonBarChart', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/bar_chart/poll_common_bar_chart.html'
  controller: ['$scope', ($scope) ->
    $scope.countFor = (option) ->
      $scope.poll.stanceData[option.name] or 0

    $scope.barTextFor = (option) ->
      "#{$scope.countFor(option)} - #{option.name}".replace(/\s/g, '\u00a0')

    percentageFor = (option) ->
      max = _.max(_.values($scope.poll.stanceData))
      return unless max > 0
      "#{100 * $scope.countFor(option) / max}%"

    backgroundImageFor = (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"

    $scope.styleData = (option) ->
      'background-image': backgroundImageFor(option)
      'background-size': "#{percentageFor(option)} 100%"
  ]
