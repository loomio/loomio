angular.module('loomioApp').directive 'pollDotVoteVotesPanelStance', (PollService, RecordLoader) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/dot_vote/votes_panel_stance/poll_dot_vote_votes_panel_stance.html'
  controller: ($scope) ->
    $scope.barTextFor = (choice) ->
      "#{choice.score} - #{choice.pollOption().name}".replace(/\s/g, '\u00a0')

    percentageFor = (choice) ->
      # max = _.max(_.map($scope.stance.stanceChoices(), (choice) -> choice.score))
      max = $scope.stance.poll().customFields.dots_per_person
      return unless max > 0
      "#{100 * choice.score / max}%"

    backgroundImageFor = (choice) ->
      "url(/img/poll_backgrounds/#{choice.pollOption().color.replace('#','')}.png)"

    $scope.styleData = (choice) ->
      'background-image': backgroundImageFor(choice)
      'background-size': percentageFor(choice)

    $scope.stanceChoices = ->
      _.sortBy($scope.stance.stanceChoices(), 'score').reverse()
