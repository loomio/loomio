angular.module('loomioApp').factory 'PollProposalOutcomeForm', ->
  templateUrl: 'generated/components/poll/proposal/outcome_form/poll_proposal_outcome_form.html'
  controller: ($scope, $translate, outcome, FormService, TranslationService, MentionService, KeyEventService) ->
    $scope.outcome = outcome.clone()
    $scope.outcome.makeAnnouncement = outcome.isNew()

    actionName = if $scope.outcome.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.outcome,
      flashSuccess: "poll_proposal_outcome_form.messages.#{actionName}"
      draftFields: ['statement']

    TranslationService.eagerTranslate $scope,
      statementPlaceholder: 'poll_common.statement_placeholder'

    MentionService.applyMentions($scope, $scope.outcome)
    KeyEventService.submitOnEnter($scope)
