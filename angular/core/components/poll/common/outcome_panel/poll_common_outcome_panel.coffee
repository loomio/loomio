angular.module('loomioApp').directive 'pollCommonOutcomePanel', (AbilityService, TranslationService, ReactionService, ModalService, PollCommonOutcomeModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/outcome_panel/poll_common_outcome_panel.html'
  controller: ($scope) ->

    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canParticipateInPoll($scope.poll)
    ,
      name: 'edit_outcome'
      icon: 'edit'
      canPerform: -> AbilityService.canSetPollOutcome($scope.poll)
      perform:    -> ModalService.open PollCommonOutcomeModal, outcome: -> $scope.poll.outcome()
    ,
      name: 'translate_outcome'
      icon: 'translate'
      canPerform: -> AbilityService.canTranslate($scope.poll.outcome())
      perform:    -> TranslationService.inline($scope, $scope.poll.outcome())
    ]

    TranslationService.listenForTranslations $scope
    ReactionService.listenForReactions $scope, $scope.poll.outcome()
