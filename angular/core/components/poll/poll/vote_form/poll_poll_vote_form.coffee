angular.module('loomioApp').factory 'PollPollVoteForm', ->
  templateUrl: 'generated/components/poll/poll/vote_form/poll_poll_vote_form.html'
  controller: ($scope, stance, option, FormService, TranslationService, MentionService, KeyEventService) ->
    $scope.stance = stance.clone()
    $scope.pollOption = option
    $scope.pollOptionIds = {} # multipleChoice uses this

    actionName = if $scope.stance.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes =
          _.map selectedOptionIds(), (id) -> {poll_option_id: id}
      flashSuccess: "poll_proposal_vote_form.messages.#{actionName}"
      draftFields: ['reason']

    selectedOptionIds = ->
      if $scope.stance.poll().multipleChoice
        _.compact(_.map($scope.pollOptionIds, (v,k) -> parseInt(k) if v))
      else
        [$scope.pollOption.id]

    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
