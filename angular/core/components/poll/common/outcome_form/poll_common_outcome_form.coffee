angular.module('loomioApp').factory 'PollCommonOutcomeForm', ->
  templateUrl: 'generated/components/poll/common/outcome_form/poll_common_outcome_form.html'
  controller: ($scope, $translate, outcome, FormService, TranslationService, MentionService, KeyEventService) ->
    $scope.outcome = outcome.clone()
    $scope.outcome.makeAnnouncement = outcome.isNew()

    actionName = if $scope.outcome.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.outcome,
      flashSuccess: "poll_common_outcome_form.outcome_#{actionName}"
      drafts: true

    TranslationService.eagerTranslate $scope,
      statementPlaceholder: 'poll_common_outcome_form.statement_placeholder'

    MentionService.applyMentions($scope, $scope.outcome)
    KeyEventService.submitOnEnter($scope)
