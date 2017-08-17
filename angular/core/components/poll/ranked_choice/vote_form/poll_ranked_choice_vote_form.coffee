angular.module('loomioApp').directive 'pollRankedChoiceVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/ranked_choice/vote_form/poll_ranked_choice_vote_form.html'
  controller: ($scope, PollService, MentionService, KeyEventService) ->
    initForm = do ->
      $scope.minimumStanceChoices  = $scope.stance.poll().customFields.minimum_stance_choices
      $scope.pollOptions           = $scope.stance.poll().pollOptions()

    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        selected = _.take $scope.pollOptions, $scope.minimumStanceChoices
        $scope.stance.stanceChoicesAttributes = _.map selected, (option, index) ->
          poll_option_id: option.id
          score:          index+1

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
