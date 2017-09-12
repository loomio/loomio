angular.module('loomioApp').directive 'outcomeCreated', (TranslationService, ReactionService, AbilityService, ModalService, PollCommonOutcomeModal) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/outcome_created.html'
  replace: true
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canParticipateInPoll($scope.eventable.poll())
    ,
      name: 'edit_outcome'
      icon: 'edit'
      canPerform: -> AbilityService.canSetPollOutcome($scope.eventable.poll())
      perform:    -> ModalService.open PollCommonOutcomeModal, outcome: -> $scope.eventable
    ,
      name: 'translate_outcome'
      icon: 'translate'
      canPerform: -> AbilityService.canTranslate($scope.eventable)
      perform:    -> TranslationService.inline($scope, $scope.eventable)
    ]

    ReactionService.listenForReactions $scope, $scope.eventable
    TranslationService.listenForTranslations $scope,
