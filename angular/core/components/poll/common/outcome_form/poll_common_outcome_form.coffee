angular.module('loomioApp').directive 'pollCommonOutcomeForm', ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/outcome_form/poll_common_outcome_form.html'
  controller: ($scope, $translate, PollService, LoadingService, TranslationService, MentionService, KeyEventService) ->
    $scope.outcome.makeAnnouncement = $scope.outcome.isNew()

    $scope.submit = PollService.submitOutcome $scope, $scope.outcome

    $scope.datesAsOptions = ->
      PollService.fieldFromTemplate $scope.outcome.poll().pollType, 'dates_as_options'

    MentionService.applyMentions($scope, $scope.outcome)
    KeyEventService.submitOnEnter($scope)
    LoadingService.listenForLoading($scope)
