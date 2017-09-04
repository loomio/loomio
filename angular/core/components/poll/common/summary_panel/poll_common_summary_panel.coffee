angular.module('loomioApp').directive 'pollCommonSummaryPanel', (AbilityService, ModalService, PollCommonFormModal, TranslationService, ReactionService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/summary_panel/poll_common_summary_panel.html'
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canParticipateInPoll($scope.poll)
    ,
      name: 'edit_poll'
      icon: 'edit'
      canPerform: -> AbilityService.canEditPoll($scope.poll)
      perform: -> ModalService.open PollCommonFormModal, poll: -> $scope.poll
    ]

    TranslationService.listenForTranslations($scope)
    ReactionService.listenForReactions($scope, $scope.poll)
