angular.module('loomioApp').directive 'pollDotVoteVotesPanelStance', (PollService, RecordLoader) ->
  scope: {stance: '=', poll: '='}
  templateUrl: 'generated/components/poll/dot_vote/votes_panel_stance/poll_dot_vote_votes_panel_stance.html'
  controller: ($scope) ->
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
      'background-size': percentageFor(option)
