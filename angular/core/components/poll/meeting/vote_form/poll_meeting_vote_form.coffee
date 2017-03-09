angular.module('loomioApp').directive 'pollMeetingVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/vote_form/poll_meeting_vote_form.html'
  controller: ($scope, PollService, MentionService, KeyEventService) ->
    $scope.vars = {}

    initForm = do ->
      $scope.pollOptionIdsChecked = _.fromPairs _.map $scope.stance.stanceChoices(), (choice) ->
        [choice.pollOptionId, true]

    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes =
          _.map _.compact(_.map($scope.pollOptionIdsChecked, (v,k) -> parseInt(k) if v)), (id) ->
            {poll_option_id: id}

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
