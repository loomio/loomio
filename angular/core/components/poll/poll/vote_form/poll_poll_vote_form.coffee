angular.module('loomioApp').directive 'pollPollVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/poll/vote_form/poll_poll_vote_form.html'
  controller: ($scope, FormService, TranslationService, MentionService, KeyEventService) ->
    $scope.vars = {}

    multipleChoice = $scope.stance.poll().multipleChoice

    initForm = do ->
      if multipleChoice
        $scope.pollOptionIdsChecked = _.fromPairs _.map $scope.stance.stanceChoices(), (choice) ->
          [choice.pollOptionId, true]
      else
        $scope.vars.pollOptionId = $scope.stance.pollOptionId()

    serializeForm = ->
      selectedOptionIds = if multipleChoice
          _.compact(_.map($scope.pollOptionIdsChecked, (v,k) -> parseInt(k) if v))
        else
          [$scope.vars.pollOptionId]

      $scope.stance.stanceChoicesAttributes =
        _.map selectedOptionIds, (id) -> {poll_option_id: id}

    actionName = if $scope.stance.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.stance,
      successCallback: -> $scope.$emit 'stanceSaved'
      prepareFn: serializeForm
      flashSuccess: "poll_poll_vote_form.stance_#{actionName}"
      draftFields: ['reason']

    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
