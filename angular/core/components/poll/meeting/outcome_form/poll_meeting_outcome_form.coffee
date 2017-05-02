angular.module('loomioApp').directive 'pollMeetingOutcomeForm', ->
  templateUrl: 'generated/components/poll/meeting/outcome_form/poll_meeting_outcome_form.html'
  controller: ($scope, $translate, PollService, TranslationService, MentionService, KeyEventService) ->
    $scope.outcome.makeAnnouncement = $scope.outcome.isNew()

    $scope.submit = PollService.submitOutcome $scope, $scope.outcome

    TranslationService.eagerTranslate $scope,
      statementPlaceholder: 'poll_common_outcome_form.statement_placeholder'

    MentionService.applyMentions($scope, $scope.outcome)
    KeyEventService.submitOnEnter($scope)
