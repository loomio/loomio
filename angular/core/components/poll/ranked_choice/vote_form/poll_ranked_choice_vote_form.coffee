angular.module('loomioApp').directive 'pollRankedChoiceVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/ranked_choice/vote_form/poll_ranked_choice_vote_form.html'
  controller: ($scope, PollService, MentionService, KeyEventService) ->
    initForm = do ->
      $scope.numChoices  = $scope.stance.poll().customFields.minimum_stance_choices
      $scope.pollOptions = _.sortBy $scope.stance.poll().pollOptions(), (option) ->
        choice = _.find($scope.stance.stanceChoices(), _.matchesProperty('pollOptionId', option.id))
        -(choice or {}).score

    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.$emit 'processing'
        selected = _.take $scope.pollOptions, $scope.numChoices
        $scope.stance.stanceChoicesAttributes = _.map selected, (option, index) ->
          poll_option_id: option.id
          score:          $scope.numChoices - index

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
