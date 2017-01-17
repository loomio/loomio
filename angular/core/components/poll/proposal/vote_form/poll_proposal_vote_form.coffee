angular.module('loomioApp').factory 'PollProposalVoteForm', ->
  templateUrl: 'generated/components/poll/proposal/vote_form/poll_proposal_vote_form.html'
  controller: ($scope, stance, option, FormService, TranslationService, MentionService, KeyEventService) ->
    $scope.stance = stance.clone()
    $scope.pollOption = option

    actionName = if $scope.stance.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes = [{ poll_option_id: $scope.pollOption.id }]
      flashSuccess: "poll_proposal_vote_form.stance_#{actionName}"
      draftFields: ['reason']

    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
