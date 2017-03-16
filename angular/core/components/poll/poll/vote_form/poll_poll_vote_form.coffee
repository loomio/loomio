angular.module('loomioApp').directive 'pollPollVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/poll/vote_form/poll_poll_vote_form.html'
  controller: ($scope, PollService, TranslationService, MentionService, KeyEventService) ->
    $scope.vars = {}

    multipleChoice = $scope.stance.poll().multipleChoice

    initForm = do ->
      if multipleChoice
        $scope.pollOptionIdsChecked = _.fromPairs _.map $scope.stance.stanceChoices(), (choice) ->
          [choice.pollOptionId, true]
      else
        $scope.vars.pollOptionId = $scope.stance.pollOptionId()

    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        selectedOptionIds = if multipleChoice
          _.compact(_.map($scope.pollOptionIdsChecked, (v,k) -> parseInt(k) if v))
        else
          [$scope.vars.pollOptionId]

        if _.any selectedOptionIds
          $scope.stance.stanceChoicesAttributes =
            _.map selectedOptionIds, (id) -> {poll_option_id: id}


    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
