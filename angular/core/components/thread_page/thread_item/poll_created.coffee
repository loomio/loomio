angular.module('loomioApp').directive 'pollCreated', (TranslationService, ReactionService, AbilityService, ModalService, PollCommonFormModal) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/outcome_created.html'
  replace: true
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canParticipateInPoll($scope.eventable.poll())
    ,
      name: 'edit_poll'
      icon: 'edit'
      canPerform: -> AbilityService.canEditPoll($scope.eventable)
      perform:    -> ModalService.open PollCommonFormModal, poll: -> $scope.eventable
    ,
      name: 'translate_outcome'
      icon: 'translate'
      canPerform: -> AbilityService.canTranslate($scope.eventable)
      perform:    -> TranslationService.inline($scope, $scope.eventable)
    ]

    ReactionService.listenForReactions $scope, $scope.eventable
    TranslationService.listenForTranslations $scope,
