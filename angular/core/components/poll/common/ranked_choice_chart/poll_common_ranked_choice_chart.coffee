angular.module('loomioApp').directive 'pollCommonRankedChoiceChart', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/ranked_choice_chart/poll_common_ranked_choice_chart.html'
  controller: ($scope) ->
    $scope.countFor = (option) ->
      $scope.poll.stanceData[option.name] or 0

    $scope.pollOptions = ->
      _.sortBy $scope.poll.pollOptions(), (option) -> -$scope.countFor(option)

    $scope.barTextFor = (option) ->
      option.name

    percentageFor = (option) ->
      max = _.max(_.values($scope.poll.stanceData))
      return unless max > 0
      "#{100 * $scope.countFor(option) / max}%"

    backgroundImageFor = (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"

    $scope.styleData = (option) ->
      'background-image': backgroundImageFor(option)
      'background-size': percentageFor(option)
