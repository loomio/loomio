angular.module('loomioApp').directive 'pollCommonRankedChoiceChart', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/ranked_choice_chart/poll_common_ranked_choice_chart.html'
  controller: ($scope) ->
    $scope.countFor = (option) ->
      ($scope.poll.stanceData or {})[option.name] or 0

    $scope.rankFor = (score) ->
      $scope.poll.customFields.minimum_stance_choices - score + 1

    $scope.votesFor = (option, score) ->
      _.sum option.stanceChoices(), (choice) ->
        1 if choice.stance().latest and choice.score == score

    $scope.scores = ->
      [$scope.poll.customFields.minimum_stance_choices..1]

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
      'width': percentageFor(option)
